# some toy analysis
require(ROCR)
require(ggplot2)
require(extrafont)
require(reshape2)
require(lubridate)
require(corrplot)
require(e1071)
require(dplyr)
require(stringr)
require(RJSONIO)
require(httr)
require(strucchange)
require(ROCR)
require(randomForest)
require(MASS)

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


AUCdata <- data.frame(`True Positive Rate`=unlist(attributes(prf)$y.values),
                      `False Positive Rate`=unlist(attributes(prf)$x.values))


ppi <- 250
Sinfo = 40
png("./images/InitialLogit.png",width=20*ppi,height=12*ppi,res=ppi)

ggplot(AUCdata,aes(y=True.Positive.Rate,x=False.Positive.Rate)) +
  geom_smooth(size=2) +
  theme_bw() +
  theme(panel.grid.major.y=element_line(color="grey50",linetype="dashed",size=0.75),
        panel.grid.major.x=element_line(color="grey50",linetype="dotted",size=0.5),
        panel.grid.minor=element_blank(),
        panel.background = element_rect(fill=grey(0.95,0.9)),
        panel.border=element_rect(color="grey50",linetype="solid",size=1),
        axis.text=element_text(family="axiformaextrabold",size=Sinfo+3),
        axis.text.x=element_text(angle=0,hjust=1,face="plain",size=Sinfo-10),
        axis.text.y=element_text(family="axiformaextrabold",size=Sinfo-5),
        axis.line = element_line(color="black"),
        axis.title.x=element_text(face="bold",family="axiformaextrabold",size=Sinfo,vjust=-0.4),
        axis.title.y=element_text(face="bold",family="axiformaextrabold",size=Sinfo,vjust=1.5),
        legend.position="right",
        legend.background=element_blank(),
        legend.key=element_blank(),
        legend.title=element_text(face="bold",family="axiformaextrabold",size=Sinfo-5),
        legend.text=element_text(family="axiformaextrabold",size=Sinfo-20,lineheight=0.25),
        legend.key.size=unit(.05,"npc"),
        plot.background = element_rect(fill=grey(0.95,0.9)),
        plot.title=element_text(family="axiformaextrabold",face="bold",hjust=0.5,size=Sinfo+20),
        strip.background = element_rect(fill=grey(0.95,0.9),color=NA),
        strip.text=element_text(family="axiformaextrabold",face="bold",size=rel(3.5))) +
  ylab("True Positive Rate") +
  xlab("False Positive Rate") +
  scale_x_continuous(labels=function(X){paste(X*100,"%",sep="")}) +
  scale_y_continuous(labels=function(X){paste(X*100,"%",sep="")})

dev.off()


betadat <- data.frame(names=names(coef(GLMmod)),values=coef(GLMmod))
betadat <- cbind(betadat,data.frame(rank=(nrow(betadat)+1)-rank(abs(betadat$values))))
rankBetas <- betadat$names
rankBetas[betadat$rank] <- betadat$names
betadat$names <- factor(as.character((betadat$names)),
                        levels=as.character(rankBetas))
#betadat[betadat$rank,] <- betadat

ppi <- 250
Sinfo = 40
png("./images/LogitLoads.png",width=20*ppi,height=12*ppi,res=ppi)

ggplot(betadat,aes(y=values,x=names)) +
  geom_bar(stat='identity') +
  theme_bw() +
  theme(panel.grid.major.y=element_line(color="grey50",linetype="dashed",size=0.75),
        panel.grid.major.x=element_line(color="grey50",linetype="dotted",size=0.5),
        panel.grid.minor=element_blank(),
        panel.background = element_rect(fill=grey(0.95,0.9)),
        panel.border=element_rect(color="grey50",linetype="solid",size=1),
        axis.text=element_text(family="axiformaextrabold",size=Sinfo+3),
        axis.text.x=element_text(angle=45,hjust=1,face="plain",size=Sinfo-10),
        axis.text.y=element_text(family="axiformaextrabold",size=Sinfo-5),
        axis.line = element_line(color="black"),
        axis.title.x=element_blank(), #element_text(face="bold",family="axiformaextrabold",size=Sinfo,vjust=-0.4),
        axis.title.y=element_text(face="bold",family="axiformaextrabold",size=Sinfo,vjust=1.5),
        legend.position="right",
        legend.background=element_blank(),
        legend.key=element_blank(),
        legend.title=element_text(face="bold",family="axiformaextrabold",size=Sinfo-5),
        legend.text=element_text(family="axiformaextrabold",size=Sinfo-20,lineheight=0.25),
        legend.key.size=unit(.05,"npc"),
        plot.background = element_rect(fill=grey(0.95,0.9)),
        plot.title=element_text(family="axiformaextrabold",face="bold",hjust=0.5,size=Sinfo+20),
        strip.background = element_rect(fill=grey(0.95,0.9),color=NA),
        strip.text=element_text(family="axiformaextrabold",face="bold",size=rel(3.5))) +
  scale_fill_manual(values=c(rgb(0, 123/360, 255/360, 0.5))) +
  ylab("Logit Betas")

dev.off()



svmfit <- svm(approved~incomeLog+soleApplicant+blackApplicant+asianApplicant+otherRaceApplicant+isFemale+
                firstLien+refinancing+homeImprovement+isHUD+isCreditUnion+isOwnerOccupied+isManufactured+
                hudSpreadLogNormalized+incomeLoanRatioLog+lowDenseArea+
                selfOwnedArea+minorityPop+totalAreaPopLog+empPerPop+payPerPop+popLogNormalized,data=subData,kernel="radial")

testIds <- runif(nrow(Xdata)*0.1,1,nrow(Xdata))
pr2 <- prediction(predict(svmfit,newdata = Xdata[testIds,-1],type="response"), Xdata[testIds,'approved'])

prf2 <- performance(pr2, measure = "tpr", x.measure = "fpr")
plot(prf2)

prRand2 <- prediction(Xdata[testIds,'approved'][runif(length(testIds),1,length(testIds))], Xdata[testIds,'approved'])
prfRand2 <- performance(prRand2, measure='tpr', x.measure='fpr')
lines(unlist(attributes(prfRand2)$x.values),unlist(attributes(prfRand2)$y.values),col="red")

auc2 <- performance(pr2, measure = "auc")
auc2 <- auc2@y.values[[1]]
auc2

AUCdata2 <- data.frame(`True Positive Rate`=c(unlist(attributes(prf)$y.values),unlist(attributes(prf2)$y.values)),
                       `False Positive Rate`=c(unlist(attributes(prf)$x.values),unlist(attributes(prf2)$x.values)),
                       type=c(rep("Initial Logit",length(unlist(attributes(prf)$y.values))),
                              rep("Support Vector Machine",length(unlist(attributes(prf2)$y.values)))))

ppi <- 250
Sinfo = 40
png("./images/SVM.png",width=20*ppi,height=12*ppi,res=ppi)

ggplot(AUCdata2,aes(y=True.Positive.Rate,x=False.Positive.Rate,color=type)) +
  geom_line(size=2) +
  theme_bw() +
  theme(panel.grid.major.y=element_line(color="grey50",linetype="dashed",size=0.75),
        panel.grid.major.x=element_line(color="grey50",linetype="dotted",size=0.5),
        panel.grid.minor=element_blank(),
        panel.background = element_rect(fill=grey(0.95,0.9)),
        panel.border=element_rect(color="grey50",linetype="solid",size=1),
        axis.text=element_text(family="axiformaextrabold",size=Sinfo+3),
        axis.text.x=element_text(angle=0,hjust=1,face="plain",size=Sinfo-10),
        axis.text.y=element_text(family="axiformaextrabold",size=Sinfo-5),
        axis.line = element_line(color="black"),
        axis.title.x=element_text(face="bold",family="axiformaextrabold",size=Sinfo,vjust=-0.4),
        axis.title.y=element_text(face="bold",family="axiformaextrabold",size=Sinfo,vjust=1.5),
        legend.position="right",
        legend.background=element_blank(),
        legend.key=element_blank(),
        legend.title=element_text(face="bold",family="axiformaextrabold",size=Sinfo-5),
        legend.text=element_text(family="axiformaextrabold",size=Sinfo-20,lineheight=0.25),
        legend.key.size=unit(.05,"npc"),
        plot.background = element_rect(fill=grey(0.95,0.9)),
        plot.title=element_text(family="axiformaextrabold",face="bold",hjust=0.5,size=Sinfo+20),
        strip.background = element_rect(fill=grey(0.95,0.9),color=NA),
        strip.text=element_text(family="axiformaextrabold",face="bold",size=rel(3.5))) +
  ylab("True Positive Rate") +
  xlab("False Positive Rate") +
  scale_x_continuous(labels=function(X){paste(X*100,"%",sep="")}) +
  scale_y_continuous(labels=function(X){paste(X*100,"%",sep="")}) +
  scale_color_manual(values=c(rgb(0, 123/360, 255/360, 0.5),rgb(85/360, 93/360, 102/360, 0.5),"black"))

dev.off()
