clear all
close all

%function memoryTask
rand('twister',sum(100*clock));%sorts out matlab randomisation problem

%% ------------------------------------------------------------------------
%Get studentNumber, age, and gender by asking for input
[studentNumber, age, G, gender] = getPptInfo;%User-defined function
pptNo = studentNumber;%Define participant number
time = getTime; %Get the current time in the format 'DD-MM_HH-MM' (user-defined function)

%% ------------------- Opening the screen ---------------------------------

Screen('Preference', 'SkipSyncTests', 1);
%PsychJavaTrouble;%UNCOMMENT WHEN GET BACK TO WORK

% Opening a new window to display stimuli
screens=Screen('Screens'); screenNumber=max(screens);
window=Screen('OpenWindow',screenNumber, [], [], [], [], [], []);

%Get the width and height of the window, the X centre and Y centre of the screen
[windowWidth, windowHeight, X0, Y0] = getInfoAboutScreen(window);%user-defined function

%Set up some things to do with the keyboard
KbName('UnifyKeyNames');
ListenChar(2);%turn on character listening but suppress output of keypresses to Matlab windows
escapeKey = KbName('ESCAPE');
nextKey = KbName('space');
presentKey = KbName('DownArrow');
absentKey = KbName('UpArrow');
HideCursor %Don't hide the cursor in this experiment

%% THESE ARE THE EXPERIMENTAL VARIABLES THAT YOU CAN CHANGE
experimentNo = 2.2;

% --- COLOUR LOOKUP ---
grey = 128;
black = 0;
white = 255;

red = [255 0 0];
green = [0 255 0];
blue = [0 0 255];
yellow = red + green;
purple = red + blue;
cyan = blue + green;

% --- FIXATION POINT ---
heightOfFix = 20;
widthOfFix = 20;
lineWidth = 3;

% --- VARIABLES TO DO WITH FEEDBACK ---
frameColour = black;
correctFrameColour = green;
incorrectFrameColour = red;
framePenWidth = 6;
vSpacing = 2;%vertical spacing of characters
wrapat = 100;%wrap text after 100 characters
XposFeedbackText = 'center';%X position of the feedback text. If you want it in the centre, type 'center'. Otherwise, put a numerical value.
YposFeedbackText = windowHeight-100;%Y position of the feedback text

hitText = 'You were CORRECT, the images were the SAME';
missText = 'You were INCORRECT, the images were the SAME';
correctRejectionText = 'You were CORRECT, the images were DIFFERENT';
falseAlarmText = 'You were INCORRECT, the images were DIFFERENT';

targetText1 = 'STUDY THIS IMAGE';
targetText2 = 'STUDY THESE IMAGES';
trialText = 'DOES THIS IMAGE MATCH ONE THAT YOU STUDIED?';
nextText = 'PRESS ANY KEY TO CONTINUE';
XposHeading = 'center';
YposHeading = 200;


% --- VARIABLES TO DO WITH TEXT ---
textSize = 30;

%% ---------------- DEFINING VARIABLES ------------------------------------
%Put the identity numbers into this list. Must be numbers only (paste list between brackets).
%Just use numbers from the "Comparisons" folder
familiarityCheck

% --- BLOCKS ---
howManyBlocks = 8;
shuffleBlocks = 1; %0 = in order; 1 = shuffled
identityCap = 20; %min number of images in each identity folder
incorrectTimePenalty = 0; %Time penalty for incorrect responses
ITI = 0; %Inter-trial Interval in seconds
demoDisplay = 0;

%% ------------------------ EDIT BLOCKS -----------------------------------

% --- VARIABLES ---
%You can allocate just one number to variables (*FOR EACH BLOCK*)
%
%                       *** NB ***
%I have changed this bit of allocating variables to blocks to save space.
%The first number corresponds to the value for Block 1, the second number
%corresponds to the value for Block 2 etc. If you need to add another block
%then just add a number to the end of each list.

%For the memory task, number of trials = number of games
numberOfTrials = {10 10 10 10 10 10 10 10}; %enter the number of trials (games) you want for each block
numberOfTargets = {1 1 2 2 4 4 8 8}; %enter the number of targets per trial you want for each block 
numberOfTargetIdentity = {1 1 2 2 4 4 8 8}; %enter the number of different target images for each trial. Must be a factor of the number of targets
targetDisplayTime = {1 1 2 2 4 4 8 8}; %how long the target image is shown for in seconds
randomiseNumberOfTargets = {0 0 0 0 0 0 0 0}; %0 = no, 1 = yes
selfTerminate = {0 0 0 0 0 0 0 0}; % 0 = Auto, 1 = Self
feedback = {0 0 0 0 0 0 0 0}; %feedback, 0 = no, 1 = yes
targetPrevalence = {1/2 1/2 1/2 1/2 1/2 1/2 1/2 1/2};
targetDelay = {3 3 3 3 3 3 3 3};


% --- LISTS ---
%You can allocate multiple numbers to lists
%e.g. list = [0 0 1] means that 1/3 of trials will have a value of 1
%NB: To add another block, copy+paste a new list under each list and change
%the number in curly brackets to the block number

%There are currently no lists

block = 1;

%% ------------------------------------------------------------------------

%Make a list of blocks
if shuffleBlocks == 1
    blockList = Shuffle(1:howManyBlocks);
else
    blockList = 1:howManyBlocks;
end

%Where to look for the images
parentDirectory = 'Images';
unfamiliarDirectory = '/UK';
unfamiliarImage = '/UK*.jpg';
familiarDirectory = '/AU';
familiarImage = '/AU*.jpg';

%Make a list of all the image files in the Comparisons and Foils folders
%[Makes a list of files (fileList) and a list with their corresponding paths (pathList)]
[unfamiliarImagesPathList, unfamiliarImagesFileList] = folderSearch(strcat(parentDirectory,unfamiliarDirectory),unfamiliarImage);%User-defined function
[familiarImagesPathList, familiarImagesFileList] = folderSearch(strcat(parentDirectory,familiarDirectory),familiarImage);%User-defined function

%Make a list of just the prefixes of all the images, so we can compare these to the targetNumList
for i = 1:numel(unfamiliarImagesFileList)%For each image
    unfamiliarImagesPrefixList(i) = str2num(unfamiliarImagesFileList{i}(3:4));%Convert from strings to numbers
end
 for i = 1:numel(familiarImagesFileList)%For each image
    familiarImagesPrefixList(i) = str2num(familiarImagesFileList{i}(3:4));%Convert from strings to numbers
end

%Group the images into identities
groupedUnfamiliarImagesPrefixList = {}; groupedUnfamiliarList = {}; groupedFamiliarImagesPrefixList = {}; groupedFamiliarList = {}; groupedUnfamiliarPathList = {}; groupedFamiliarPathList = {};
for i = 1:numel(familiarIdentityNumList)%for each target
    groupedFamiliarImagesPrefixList{i} = familiarImagesPrefixList(familiarImagesPrefixList == familiarIdentityNumList(i));
    groupedFamiliarList{i} = familiarImagesFileList(familiarImagesPrefixList == familiarIdentityNumList(i));%remember foils aren't in the identity list
    groupedFamiliarPathList{i} = familiarImagesPathList(familiarImagesPrefixList == familiarIdentityNumList(i));
end

for i = 1:numel(unfamiliarIdentityNumList)%for each target
    groupedUnfamiliarImagesPrefixList{i} = unfamiliarImagesPrefixList(unfamiliarImagesPrefixList == unfamiliarIdentityNumList(i));
    groupedUnfamiliarList{i} = unfamiliarImagesFileList(unfamiliarImagesPrefixList == unfamiliarIdentityNumList(i));
    groupedUnfamiliarPathList{i} = unfamiliarImagesPathList(unfamiliarImagesPrefixList == unfamiliarIdentityNumList(i));
end

%%
TargetPositions
gridAssignment = randperm(gridColumnCount*gridRowCount);

%%
unfamiliarTargetImageIndices = Shuffle(1:numel(groupedUnfamiliarList));
familiarTargetImageIndices = Shuffle(1:numel(groupedFamiliarList));


experimentTrial = 0; endExperiment = 0; blockOrder = 0; endTrial = 0;
unfamiliarImageIndex = 1; familiarImageIndex = 1; response = 0; RT = 0; correctType = 0; correct = 0;

DATAmatrix = []; heading = {};

Screen('FillRect',window, grey);
Screen('TextFont',window, 'Arial');
Screen('TextSize',window, 32);


for block = blockList
    blockOrder = blockOrder+1;
    if endExperiment == 1; break; end

    if blockOrder == 1 %% PracticeTrials
        startExperimentImage(window,windowWidth,windowHeight,Y0,nextKey);
        startPracticeTrials(window,windowWidth,windowHeight,Y0,nextKey);
        practiceExampleImage(window,windowWidth,windowHeight,presentKey,absentKey,targetPosition,targetArrayPosition, X0, Y0);
        endPracticeTrials(window,windowWidth,windowHeight,Y0,nextKey);
    end
    
    targetType = Shuffle([zeros(1,(numberOfTrials{block}*(1-targetPrevalence{block}))),ones(1,(numberOfTrials{block}*targetPrevalence{block}))]);
    targetTest = Shuffle(repmat(1:numberOfTargets{block},[1,ceil(numberOfTrials{block}/numberOfTargets{block})]));
    
    for trial = 1:numberOfTrials{block}
            experimentTrial = experimentTrial+1;
            whichImage = [];
            targetIdentity = {};
            endTrial = 0; whichClick = 0;
            if endExperiment == 1; break; end

            gridAssignment = randperm(gridColumnCount*gridRowCount);
            
            if mod(block,2) == 1
                    trialType = 1; %%unfamiliar
                        if unfamiliarImageIndex >= numel(groupedUnfamiliarList)
                            unfamiliarImageIndex = 1;                            
                        end
                        whichImage(1:numberOfTargetIdentity{block}) = unfamiliarTargetImageIndices(unfamiliarImageIndex);
                        unfamiliarImageIndex = unfamiliarImageIndex+1;
            elseif mod(block,2) == 0
                    trialType = 2; %%familiar
                        if familiarImageIndex >= numel(groupedFamiliarList)
                            familiarImageIndex = 1;
                        end
                        whichImage(1:numberOfTargetIdentity{block}) = familiarTargetImageIndices(familiarImageIndex);
                        familiarImageIndex = familiarImageIndex+1;
            end
                
            targetImages = {};
            allTargetImages = {};
            whichFoilImage = [];
            imageSelection = [];
            targetImageNumber = zeros(1,4);
            foilImageNumber = [];
            
           
            if randomiseNumberOfTargets{block} ==1
                trialTargets = ceil(rand*numberOfTargets{block});
            else
                trialTargets = numberOfTargets{block};
            end
            
            targetsPerIdentity = trialTargets/numberOfTargetIdentity{block};

            imageSelection = randperm(identityCap);
            id = 1;
            
            if trialType == 1
                    targetNumber = unfamiliarIdentityNumList(whichImage(1))';
                    for n = 1:numberOfTargetIdentity{block}
                        for i = 1:targetsPerIdentity
                            if id > identityCap
                                id = 1;
                            end
                            targetImages{n,i} = imread(strcat(groupedUnfamiliarPathList{whichImage(n)}{imageSelection(id)}, '/', groupedUnfamiliarList{whichImage(n)}{imageSelection(id)}));
                            allTargetImages{end+1} = targetImages{n,i};
                        end
                        targetImageNumber(n) = imageSelection(id);
                        id = id+1;

                    end
                            if id > identityCap
                                id = 1;
                            end
                        foilImage = imread(strcat(groupedUnfamiliarPathList{whichImage(n)}{imageSelection(id)},'/', groupedUnfamiliarList{whichImage(n)}{imageSelection(id)}));
                        foilImageNumber = imageSelection(id);
                        id = id+1;
            elseif trialType == 2;
                    targetNumber = familiarIdentityNumList(whichImage(1))';
                    for n = 1:numberOfTargetIdentity{block}
                        for i = 1:targetsPerIdentity
                            if id > identityCap
                                id = 1;
                            end
                            targetImages{n,i} = imread(strcat(groupedFamiliarPathList{whichImage(n)}{imageSelection(id)}, '/', groupedFamiliarList{whichImage(n)}{imageSelection(id)}));
                            allTargetImages{end+1} = targetImages{n,i};
                        end
                        targetImageNumber(n) = imageSelection(id);
                        id = id+1;
                    end
                            if id > identityCap
                                id = 1;
                            end
                        foilImage = imread(strcat(groupedFamiliarPathList{whichImage(n)}{imageSelection(id)},'/', groupedFamiliarList{whichImage(n)}{imageSelection(id)}));
                        foilImageNumber = imageSelection(id);
                        id = id+1;
            end
        maskImage = imread(strcat('twirled/u05tp.jpg'));          
            
            %% -------------------- Make textures -----------------------------
        allTextures = [];
        targetTexture = [];
        Screen('FillRect',window, grey);
        Screen('TextFont',window, 'Arial');
        Screen('TextSize',window, 32);
        
        maskTexture = Screen('MakeTexture', window, maskImage);
        
        for n = 1:trialTargets
            targetTexture(end+1) = Screen('MakeTexture', window, targetImages{n});
        end
        
        if targetType(trial) == 0
            allTextures(end+1) = Screen('MakeTexture', window, foilImage);
            imageShown = foilImageNumber;
        elseif targetType(trial)  == 1
            allTextures(end+1) = Screen('MakeTexture', window, targetImages{targetTest(trial)});
            imageShown = targetImageNumber(targetTest(trial));
        end

        
                %% -------------- Blank screen ---------------------------
        Screen('FillRect', window ,grey);
        Screen('Flip',window);        
        
        %% -------------- Target Screen ---------------------------
        if trialTargets == 1
            DrawFormattedText(window, targetText1, XposHeading, YposHeading, white, wrapat, [], [], vSpacing);
        else
            DrawFormattedText(window, targetText2, XposHeading, YposHeading, white, wrapat, [], [], vSpacing);
        end
        
        Screen('DrawTextures', window, targetTexture, [], targetArrayPosition{trialTargets});
        Screen('Flip',window);
        WaitSecs(targetDisplayTime{block});
        
                %% -------------- Blank screen (3000 ms) ---------------------------
%         drawFixationSquare(window,heightOfFix,widthOfFix,targetPosition',black);%drawFixationSquare(windowptr,height,width,where,colour)
        Screen('DrawLine', window, black, X0-widthOfFix/2, Y0, X0+widthOfFix/2, Y0,lineWidth);
        Screen('DrawLine', window, black, X0, Y0-heightOfFix/2, X0, Y0+heightOfFix/2,lineWidth);
        Screen('Flip',window);
        WaitSecs(0.5);
        Screen('FillRect', window ,grey);
        Screen('DrawTextures', window, maskTexture, [], targetPosition);
        Screen('Flip',window);
        WaitSecs(1);
        Screen('Flip',window);
        WaitSecs(targetDelay{block});
        
        
        %% ----------------- Present the images ---------------------------
        DrawFormattedText(window, trialText, XposHeading, YposHeading, white, wrapat, [], [], vSpacing);
        Screen('DrawTextures', window, allTextures, [], targetPosition);
        Screen('Flip',window);
        tstart = tic;
        while KbCheck; end %Wait until all keys have been released
        while 1 %while 1 is always true, so this loop will continue indefinitely.
            if endExperiment == 1; break; end
            [ keyIsDown, seconds, keyCode ] = KbCheck; %Check the state of the keyboard. See if a key is currently pressed on the keyboard.
            
            if keyIsDown
                find(keyCode);
                KbName(keyCode);
                whichKey = find(keyCode);
                %If a meaningful key was pressed
                if keyCode(escapeKey); endExperiment = 1; break; end
                if keyCode(presentKey) || keyCode(absentKey)
                    %this records the number of the image that was selected (1 or 2), NOT the side that was chosen
                    if keyCode(presentKey); response = 1; end
                    if keyCode(absentKey); response = 0; end
                    RT = toc(tstart);
                    Screen('Flip',window);
                    break;
                end
                
                while KbCheck; end %Once a key has been pressed we wait until all keys have been released before going through the loop again
                
            end%if keyIsDown
        end%while 1
        
                %% ----------------- Check if Correct ---------------------------
        
        if response==targetType(trial)
            correct = 1;
            feedbackTextColour = correctFrameColour;
            if targetType(trial)== 1
                feedbackText = hitText;
                correctType = 3;
            elseif targetType(trial)==0
                feedbackText = correctRejectionText;
                correctType = 1;
            end
        else
            correct = 0;
            feedbackTextColour = incorrectFrameColour;
            if targetType(trial)== 1
                feedbackText = missText;
                correctType = 4;
            elseif targetType(trial)==0
                feedbackText = falseAlarmText;
                correctType = 2;
            end
        end

        if feedback{block} == 1%if feedback is on
            DrawFormattedText(window, feedbackText, XposFeedbackText, YposFeedbackText, feedbackTextColour, wrapat, [], [], vSpacing);
            %Re-display images after feedback
            Screen('DrawTextures', window, allTextures, [], targetPosition);
            Screen('Flip',window);
        else
            DrawFormattedText(window, nextText, XposFeedbackText, YposFeedbackText, white, wrapat, [], [], vSpacing);
            Screen('Flip',window);
        end
        
        while KbCheck; end; KbWait;


        
        %% ----------------- Data Saving ---------------------------

                                pos = 0; heading = {};
                                pos=pos+1;  DATAmatrix(experimentTrial,pos) = pptNo;                                        heading{pos} = 'Ppt no.';
                                pos=pos+1;  DATAmatrix(experimentTrial,pos) = G;                                            heading{pos} = 'Gender (1=F, 2=M)';
                                pos=pos+1;  DATAmatrix(experimentTrial,pos) = age;                                          heading{pos} = 'Age';
                                pos=pos+1;  DATAmatrix(experimentTrial,pos) = blockOrder;                                   heading{pos} = 'Block order (the order blocks were presented)';
                                pos=pos+1;  DATAmatrix(experimentTrial,pos) = block;                                        heading{pos} = 'Block (specific block presented)';
                                pos=pos+1;  DATAmatrix(experimentTrial,pos) = experimentTrial;                              heading{pos} = 'Experiment Trial';
                                pos=pos+1;  DATAmatrix(experimentTrial,pos) = trial;                                        heading{pos} = 'Trial';                            
                                pos=pos+1;  DATAmatrix(experimentTrial,pos) = trialType;                                    heading{pos} = 'Image Type (1 = Unfamiliar, 2 = Familiar)';                                 
                                pos=pos+1;  DATAmatrix(experimentTrial,pos) = targetType(trial);                            heading{pos} = 'Trial Type (0 = Different, 1 = Same)';
                                pos=pos+1;  DATAmatrix(experimentTrial,pos) = trialTargets;                                 heading{pos} = 'Number of Targets';
                                pos=pos+1;  DATAmatrix(experimentTrial,pos) = numberOfTargetIdentity{block};                heading{pos} = 'Number of Target Identities';                               
                                pos=pos+1;  DATAmatrix(experimentTrial,pos) = targetNumber;                                 heading{pos} = 'Target Number';
                                pos=pos+1;  DATAmatrix(experimentTrial,pos) = targetImageNumber(1);                         heading{pos} = 'Target 1';                                
                                pos=pos+1;  DATAmatrix(experimentTrial,pos) = targetImageNumber(2);                         heading{pos} = 'Target 2';                                
                                pos=pos+1;  DATAmatrix(experimentTrial,pos) = targetImageNumber(3);                         heading{pos} = 'Target 3';                                
                                pos=pos+1;  DATAmatrix(experimentTrial,pos) = targetImageNumber(4);                         heading{pos} = 'Target 4';                                
                                pos=pos+1;  DATAmatrix(experimentTrial,pos) = imageShown;                                   heading{pos} = 'Image Shown';
                                pos=pos+1;  DATAmatrix(experimentTrial,pos) = response;                                     heading{pos} = 'Response (0=said absent, 1=said present)';
                                pos=pos+1;  DATAmatrix(experimentTrial,pos) = correct;                                      heading{pos} = 'Correct';
                                pos=pos+1;  DATAmatrix(experimentTrial,pos) = correctType;                                  heading{pos} = 'Response Type (1=CR,2=FA,3=Hit,4=Miss)';
                                pos=pos+1;  DATAmatrix(experimentTrial,pos) = RT;                                           heading{pos} = 'Response Latency';


%         end%while
        
                    %Save the headings to a .mat file
                    headingsFilename = 'headings.mat';
                    save(headingsFilename,'heading');
                    %Save the data as you go
                    variablesFilename = strcat('saveVariables/',num2str(pptNo),'_saveVariables','.mat');
                    save(variablesFilename);
                    trialDATAmatrix = DATAmatrix(experimentTrial,:);
                    trialDATAfilename = strcat('Raw_Data/exp',num2str(experimentNo),' ppt',num2str(pptNo),' gender [', gender,'] age [', num2str(age),'] time [',time,'].m');
                    save(trialDATAfilename,'trialDATAmatrix','-ascii', '-tabs','-append');

   end%for trial
        
    if endExperiment ~= 1 && block > 0 && block ~= blockList(end)
       takeBreak(window,windowWidth,windowHeight,Y0,nextKey);
    end
    
end%for block

                    
%% ---------------- End experiment ----------------------------------------
while KbCheck; end %Wait until all keys have been released

ShowCursor;

finishExperiment(window,windowWidth,windowHeight,Y0);%Display finish experiment screen

ListenChar(1);%turn on character listening


Screen('Close',window);
