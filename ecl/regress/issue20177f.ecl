/*##############################################################################

    HPCC SYSTEMS software Copyright (C) 2018 HPCC Systems®.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
############################################################################## */

inputRecord :=
            RECORD
string20        surname;
string10        forename;
string3         age;
string          extra1;
string          extra2;
string          extra3;
string          extra4;
            END;

nvRecord := { string name, string value };
nvRecords := { DATASET(nvRecord) values };

names := dataset([
    { 'Gavin', 'Smith', '34', 'a', 'b', 'c', 'd' },
    { 'John', 'Doe', '32', 'x', 'a', 'abc', 'q' }
    ], inputRecord);


mkpair(string x, string y) := TRANSFORM(nvRecord, SELF.name := x; SELF.value := y);

mkRows(string x, string y) := DATASET([mkpair(x,y), mkpair(x,y+1)]);

mknv(string3 c, inputRecord l) :=
    CASE(c,
     '1'=>mkRows('surname', l.surname),
     '2'=>mkRows('forename', l.forename),
     '3'=>mkRows('age', l.age),
     '5'=>mkRows('extra1', l.extra1),
     '6'=>mkRows('extra2', l.extra2),
     '7'=>mkRows('extra3', l.extra3),
     '8'=>mkRows('extra4', l.extra4),
     mkRows('','')
     );

n := NORMALIZE(names, 8, TRANSFORM(nvRecords, SELF.values := mknv(NOFOLD((string1)COUNTER), LEFT)));
output(n);
