%% Plot practice trial data
figure('color','white','name','Practice Trials: Staircases');
hold on;
plot(1:pdata(1).trialCount,10.^pdata(1).intensity(1:pdata(1).trialCount),'r-');
correct1 = pdata(1).response(1:pdata(1).trialCount);
correctX1 = find(correct1);
correctY1 = 10.^pdata(1).intensity(correctX1);
incorrectX1 = find(~correct1);
incorrectY1 = 10.^pdata(1).intensity(incorrectX1);
scatter(correctX1,correctY1,'rv');
scatter(incorrectX1,incorrectY1,'r^');

plot(1:pdata(2).trialCount,10.^pdata(2).intensity(1:pdata(2).trialCount),'c-');
correct2 = pdata(2).response(1:pdata(1).trialCount);
correctX2 = find(correct2);
correctY2 = 10.^pdata(2).intensity(correctX2);
incorrectX2 = find(~correct2);
incorrectY2 = 10.^pdata(2).intensity(incorrectX2);
scatter(correctX2,correctY2,'cv');
scatter(incorrectX2,incorrectY2,'c^');

set(gca,'yscale','log')
axis square;
box off;