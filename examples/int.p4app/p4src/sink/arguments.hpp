/*
 * arguments.hpp: Command line options processing for Netcope P4 INT processing example.
 * Copyright (C) 2018 Netcope Technologies, a.s.
 * Author(s): Tomas Zavodnik <zavodnik@netcope.com>
 */

/*
 * This file is part of Netcope distribution (https://github.com/netcope).
 * Copyright (c) 2018 Netcope Technologies, a.s.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef __HEADER_FILE_ARGUMENTS
#define __HEADER_FILE_ARGUMENTS

#include <iostream>
#include <stdexcept>
#include <unistd.h>

extern const char *__progname; //!< Name of application executable.

/**
 * \brief Command line options.
 */
class arguments {

    private:

        static const char *ARGUMENTS; //!< Supported options.

    public:

        /**
         * \brief Basic constructor, process command line arguments given to application main function.
         * @param argc Number of arguments.
         * @param argv Arguments themself.
         */
        arguments(int argc, char * const argv[]);

        /**
         * \brief Display usage (list of supported options) of the application.
         */
        static inline void usage();

        int card_id;  //!< Card to use.
        int rx_queue; //!< RX queue to use for metadata.
        bool help;    //!< Display of help (usage) message requested.
        char *ip;     //!< Target IPv4 address for Telemetry reports.
        int port;     //!< Target UDP port for Telemetry reports.
        bool original;//!< Keep original packets, don't remove INT on output.
        bool verbose; //!< Verbose mode.
};

const char *arguments::ARGUMENTS = "d:r:t:p:hvo";

inline void arguments::usage() {
    std::cout << "--------------------------------------------------------------------------------" << std::endl;
    std::cout << "--------------------          INT example         ------------------------------" << std::endl;
    std::cout << "--------------------------------------------------------------------------------" << std::endl;
    std::cout << "-                                                                              -" << std::endl;
    std::cout << "--------------------------------------------------------------------------------" << std::endl;
    std::cout << "Usage: np4_int [-hvo] [-d card] -r queue -t ip [-p port]" << std::endl;
    std::cout << "  -d card  Card to use (default: 0)" << std::endl;
    std::cout << "  -r queue RX queue to use for metadata" << std::endl;
    std::cout << "  -t ip    Target IPv4 address for Telemetry reports" << std::endl;
    std::cout << "  -p port  Target UDP port for Telemetry reports (default: 32766)" << std::endl;
    std::cout << "  -o       Keep original packets, don't remove INT on output" << std::endl;
    std::cout << "  -h       Writes out help" << std::endl;
    std::cout << "  -v       Verbose mode" << std::endl;
    std::cout << "--------------------------------------------------------------------------------" << std::endl;
}

arguments::arguments(int argc, char * const argv[]) :
    card_id(0),
    rx_queue(-1),
    help(false),
    ip(NULL),
    port(32766),
    original(false),
    verbose(false)
    {
    int c;
    opterr = 0; // silent getopt
    while((c = getopt(argc, argv, ARGUMENTS)) != -1)
        switch(c) {
            case 'r':
                rx_queue = atoi(optarg);
                break;
            case 'h':
                help = true;
                return;
            case 'd':
                card_id = atoi(optarg);
                break;
            case 't':
                ip = optarg;
                break;
            case 'p':
                port = atoi(optarg);
                break;
            case 'v':
                verbose = true;
                break;
            case 'o':
                original = true;
                break;
            case '?':
                throw std::runtime_error(std::string() + "unknown option '" + (char)optopt + "'");
            case ':':
                throw std::runtime_error(std::string() + "missing argument for option '" + (char)optopt + "'");
            default:
                throw std::runtime_error(std::string() + "option '" + (char)optopt + "'not implemented");
        }
    argc -= optind;
    argv += optind;
    if(argc != 0 || rx_queue < 0 || ip == NULL)
        throw std::runtime_error("stray arguments");
}

#endif
