from itertools import chain, combinations

def powerset(iterable):
    "powerset([1,2,3]) --> () (1,) (2,) (3,) (1,2) (1,3) (2,3) (1,2,3)"
    s = list(iterable)
    return chain.from_iterable(combinations(s, r) for r in range(len(s)+1))

def print_p4_state(bytes):
    res = "state parse_int_data_{} {{\n".format(bytes * 8)
    res += "    pkt.extract(hdr.int_data, {});\n".format(bytes * 8)
    res += "    meta.int_len_bytes = {};\n".format(bytes + 12) # int shim and header
    res += "    transition accept;\n"
    res += "}\n"
    print(res)

def to_hex(x, i):
    return "{0:#0{1}x}".format(x, i+2)

def mask_to_int(msk):
    v = 0
    for i in msk:
        v += pow(2, i)
    return v

def mask_to_hex(msk):
    return to_hex(mask_to_int(msk), 2)

hdr_byte_sizes = [4, 4, 4, 4, 8, 8, 4, 4, ]

# Computes unique sizes
sizes = set()
for cmb in list(powerset(hdr_byte_sizes))[1:]:
    size = sum(cmb)
    sizes.add(size)
# Up to 4 previous blobs for each size
state_sizes = set()
for size in sizes:
    s = [size*i for i in range(1, 5)]
    for e in s:
        state_sizes.add(e)
state_sizes = list(state_sizes)
state_sizes.sort()


# First compute state selectors
for bytes in state_sizes:
    # Add 3 words for headers
    print("(8w{}): parse_int_data_{};".format(to_hex(int(bytes / 4) + 3, 2), bytes * 8))

print()

# Then output parser states
for bytes in state_sizes:
    print_p4_state(bytes)
exit()

