cp ../../p4src int.p4app/ -r
sudo cp p4app /usr/local/bin
sudo p4app run int.p4app --manifest int_v1.0.json
rm int.p4app/p4src -rf
