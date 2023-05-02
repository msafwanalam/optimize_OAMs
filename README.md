# How to use
 
 1) Start the AI script
 2) Open the Full_Display labview progam and start it.
 3) Open Beamage software and open the pipeline for labview
 4) Within labview program, press connect beamage program 
 5) Fix the settings for the beamage software so that the definition is 1/e2 and that the orientation is at 0 degrees
 6) To start the whole AI, we need to first edit the beam_values.csv files. To do this, open powershell and run this command: 
    - (Get-Item "C:\Users\Ford\Documents\Gentec-EO\beamage.bmp").LastWriteTime=("3 August 2019 17:10:00")
    - If desired, you can run the zero_all_beam_values.m program to zero all of the values in the csv file.
    - Also, if the diameter needs to be found, use the find_diameter script to find the diameter of the given image and change the diameter variable in the AI script
  
Known bugs: 
- Sometimes, when first running the AI script, the image input is all black. When the beamage software first starts up, sometimes just a black image is taken. To fix this just rerun the AI script and edit the beam_values.csv file and then it should work fine.
- The computer runs out of memory at times. This is totally fine, just run all the steps again but keep the beam_values the same and it should keep going from where it left off

    

