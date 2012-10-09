INSTALL INSTRUCTION:

DISCLAIMER:
This script package is developed to be used as a fresh install.
Using it to update your system might or might not work. :)

Prerequisites:
- GitHub account with uploaded id_rsa.pub (public ssh-key)
- Copy your id_rsa.pub, id_rsa and known_host files into the /Install folder from ~/.ssh folder of authenticated machine
- Windows 7, 64 bit
- Powershell installed
- For 64 bit compiling or redistribution: Microsoft Visual Studio 2010 already installed

Caveat:
- Only support static CustusX3 builds atm, Qt can and will be buildt with shared/dynamic building.
- SSC Tests and Examples does not build on Windows 32 bit.
- CX Test does not build on Windows 32 bit.
- UltrasonixServer does not build on Windows 32 bit.

Install:
-1) Make sure Windows has installed ALL updates!
0) Edit Config.ps1 (if needed)
1) Start -> Search for cmd -> Right click -> Run as Administrator
2) C:\User\dev\Desktop\Installer\> Install.bat
3a) If ITK-Snap selected: Click "Repair Microsoft Visual C++ 2010 x64 Redistributable to its original state." -> Next -> Finish
    OR
3b) If ITK-Snap selected: I have read and accepted the license terms -> Install -> Finish
4) Wait for the script to finish
5) Press Enter to convert machine to developer machine, Ctrl+C if not.


PROBLEM SOLVING:

(Problem 1) 
After installing eclipse I get the following error:
"A Java Runtime Environment (JRE) or Java Development Kit (JDK)
must be available in order to run Eclipse. No Java virtual machine
was found after searching the following locations:
..."
(Solution 1)
Just install either the latest JRE (or JDK).

(Problem 2)
Could not use Qt 4.8.1 that comes with an installer and that is precompiled. 
(Solution 2)
The source was then downloaded to your computer, you now need to build it
yourself, as 32 bit and/or 64 bit. 
THIS IS A INSOURCE BUILD, this means you need a complete source folder for 
each type of build (32/64bit) you want to do.
Do this:
1.	Use Visual Studio Command Prompt (32bit) or Visual Studio 2005 x64 Win64 Command Prompt (64bit).
2.	Configuring will take 30ish minutes to finish:
    1.	Cd to source folder
    2.	> configure -mp -debug-and-release -opensource
        1.	-mp = multi processor build
        2.	–debug-and-release = builds both release and debug libraries.
    3.	Accept license, "y + enter"
3.	> nmake 
    1.	Can take many hours to finish.
    
(Problem 3)
Anti-virus finds potentially harmfull program, something about the compiler.
(Solution3)
Tell anti-virus to ignore.

(Problem 4)
When configuring ITK the following error occurs:
"CMake Error at CMakeLists.txt:22 (message):
  ITK build directory path length is too long (51 > 50).Please set the ITK
  build directory to a directory with a shorter path."
http://www.mail-archive.com/insight-developers@itk.org/msg00181.html
(Solution4)
Get CMake 2.8.9 or higher.

