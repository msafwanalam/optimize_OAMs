# How to use
 1) Run initialize_beam_values and choose if you are using OAM+1 or whichever one. Open AI and change theta value using the approprate OAM. 
 2) Start the AI script
 3) Open the Full_Display labview progam and start it.
 4) Open Beamage software and open the pipeline for labview
 5) Within labview program, press connect beamage program 
 6) Fix the settings for the beamage software so that the definition is 1/e2 and that the orientation is at 0 degrees
 7) To start the whole AI, we need to first edit the beam_values.csv files. To do this, open powershell and run this command: 
    - (Get-Item "C:\Users\Ford\Documents\SafwansAutomation\optimize_OAMs-main\optimize_OAMs-main\beam_values.csv").LastWriteTime=("10 August 2019 17:10:00")
    - If desired, you can run the zero_all_beam_values.m program to zero all of the values in the csv file.
    - Also, if the diameter needs to be found, use the find_diameter script to find the diameter of the given image and change the diameter variable in the AI script
  
Known bugs: 
- Sometimes, when first running the AI script, the image input is all black. When the beamage software first starts up, sometimes just a black image is taken. To fix this just rerun the AI script and edit the beam_values.csv file and then it should work fine.
- Recently, the beamage software doesn't seem to properly connect. Usually this is fixed by closing the labview and beamage software and trying again.
- The computer runs out of memory at times. This is totally fine, just run all the steps again but keep the beam_values the same and it should keep going from where it left off

    

