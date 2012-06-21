INSTALL INSTRUCTION:

DISCLAIMER:
This script package is developed to be used as a fresh install.
Using it to update your system might or might not work. :)

Prerequisites:
- Windows 7
- Microsoft Visual Studio 2010 already installed
- Install.bat and GetTools.ps1 (Must be in the same folder!)

Install:
1) Start -> Search for cmd -> Right click -> Run as Administrator
2) C:\Path_to_files\> Install.bat
3) Enter your name and email address (needed for configuring git)
3) Wait for it to finish


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
