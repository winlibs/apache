How to apache 2.4 build
========================
Steps: 
1.) Extract the zip to a folder 
2.) Make sure you have installed the prerequisites and the PATH variable has been set(checkbox in installer): 
- Visual Studio VC10 
- Windows SDK 7.1 
- Python (PATH variable set) 
- Perl (PATH variable set) 
- Cmake (PATH variable set) 
3.) Check and Modify the path configuration in build_2.4.2.bat (especially VC100_VARS_BAT). 
4.) Execute build_2.4.2.bat. 
5.) Wait a long time until cmake-gui spawns and follow the instructions at the gui 
6.) Close cmake-gui and wait until visual studio spawns, follow the instructions in the console, save and close the solution. Press a key afterwards 
7.) Wait until visual studio spawns again, and follow the instructions in the console. Press a key afterwards. 
8.) Wait untill the build is done 