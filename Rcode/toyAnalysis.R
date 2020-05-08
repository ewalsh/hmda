# some toy analysis
require(ROCR)
obsIds <- runif(nrow(Xdata)*0.1,1,nrow(Xdata))
subData <- Xdata[obsIds,]

GLMmod <- glm(approved~incomeLog+soleApplicant+blackApplicant+asianApplicant+otherRaceApplicant+isFemale+
                firstLien+refinancing+homeImprovement+isHUD+isCreditUnion+isOwnerOccupied+isManufactured+
                hudSpreadLogNormalized+incomeLoanRatioLog+lowDenseArea+
                selfOwnedArea+minorityPop+totalAreaPopLog+empPerPop+payPerPop+popLogNormalized,
              family=binomial(link='logit'),data=subData)
summary(GLMmod)

testIds <- runif(nrow(Xdata)*0.1,1,nrow(Xdata))
pr <- prediction(predict(GLMmod,newdata = Xdata[testIds,-1],type="response"), Xdata[testIds,'approved'])

prf <- performance(pr, measure = "tpr", x.measure = "fpr")
plot(prf)

prRand <- prediction(Xdata[testIds,'approved'][runif(length(testIds),1,length(testIds))], Xdata[testIds,'approved'])
prfRand <- performance(prRand, measure='tpr', x.measure='fpr')
lines(unlist(attributes(prfRand)$x.values),unlist(attributes(prfRand)$y.values),col="red")

auc <- performance(pr, measure = "auc")
auc <- auc@y.values[[1]]
auc
rm(GLMmod)
