# TODO: change this into a real CMake macro to find the argp dev library / header
Message("Building argp-standalone-1.3 for argument parsing")
Set(ARGPDIR ${CMAKE_CURRENT_SOURCE_DIR} CACHE INTERNAL "")
Set(ARGPLIB argp CACHE INTERNAL "")

add_definitions(-DHAVE_MALLOC_H -DHAVE_STDARG_H -DHAVE_STRERROR)
add_library(argp SHARED argp.def
    argp-ba.c
    argp-eexst.c
    argp-fmtstream.c
    argp-help.c
    argp-parse.c
    argp-pv.c
    argp-pvh.c
    mempcpy.c
    strcasecmp.c
    strchrnul.c
    strndup.c
    vsnprintf.c)
