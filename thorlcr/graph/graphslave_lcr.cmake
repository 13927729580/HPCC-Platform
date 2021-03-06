################################################################################
#    HPCC SYSTEMS software Copyright (C) 2012 HPCC Systems®.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
################################################################################

# Component: graphslave_lcr 
#####################################################
# Description:
# ------------
#    Cmake Input File for graphslave_lcr
#####################################################

project( graphslave_lcr ) 

set (    SRCS 
         thgraphslave.cpp 
    )

include_directories ( 
         ./../thorutil 
         ./../../fs/dafsclient 
         ./../../system/jhtree 
         ./../../system/mp 
         ./../../common/workunit 
         ./../shared 
         ./../../common/deftype 
         ./../../system/include 
         ./../../dali/base 
         ./../../rtl/include 
         ./../../common/dllserver 
         ./../slave 
         ./../../system/jlib 
         ./../mfilemanager 
         ./../../rtl/eclrtl 
         ./../../common/thorhelper 
    )

HPCC_ADD_LIBRARY( graphslave_lcr SHARED ${SRCS} )
set_target_properties(graphslave_lcr PROPERTIES 
    COMPILE_FLAGS -D_USRDLL
    DEFINE_SYMBOL GRAPHSLAVE_EXPORTS )
install ( TARGETS graphslave_lcr RUNTIME DESTINATION ${EXEC_DIR} LIBRARY DESTINATION ${LIB_DIR} )
target_link_libraries ( graphslave_lcr 
         jlib
         nbcd 
         eclrtl 
         deftype 
         thorhelper 
         dafsclient 
         dalibase 
         environment 
         dllserver 
         workunit 
         thorcodectx_lcr 
         jhtree 
         graph_lcr 
    )


