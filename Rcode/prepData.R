## prepare data 
# source("getData.R")

tmpSub <- data_lar[,c('action_taken','action_taken_name')]
dataDefs <- data.frame(name=unique(data_lar$action_taken_name),
                       code=sapply(unique(data_lar$action_taken_name),function(nm, tmpSub){
                         tmpSub$action_taken[grep(TRUE,as.character(nm) == as.character(tmpSub$action_taken_name))[1]]
                       },tmpSub))
successCodes <- c(1, 2)
failCodes <- c(3, 7)

## drop data we don't want to include 
# a mortgage purchased by another lender on secondary market
data_lar2 <- data_lar[grep(TRUE,data_lar$action_taken != 6),]
drop1 <- nrow(data_lar) - nrow(data_lar2)
print(paste('dropped',drop1,'from puchase filtering'))
# closed for incompleteness
data_lar2 <- data_lar2[grep(TRUE, data_lar2$action_taken != 5),]
drop2 <- nrow(data_lar) - nrow(data_lar2) - drop1
print(paste('dropped',drop2,'from incompleteness filtering'))
# withdrawn by applicant 
data_lar2 <- data_lar2[grep(TRUE, data_lar2$action_taken != 4),]
drop3 <- nrow(data_lar) - nrow(data_lar2) - drop1 - drop2
print(paste('dropped',drop3,'from withdrawal filtering'))
# no income data 
data_lar3 <- data_lar2[grep(TRUE,!is.na(data_lar2$applicant_income_000s)),]
drop4 <- nrow(data_lar2) - nrow(data_lar3)
print(paste('dropped',drop4,'from income missingness'))

# function to transform Y variable 
approvedTransform <- function(action_code, successCodes, failCodes){
  out <- NA
  if(sum(action_code == successCodes) > 0){
    out <- 1
  }
  if(sum(action_code == failCodes) > 0){
    out <- 0
  }
  return(out)
}

# function to transform income to distribution function 
incomeLog <- log(data_lar3$applicant_income_000s,base=10) # should think about per county

# functions for race transforms 
cnames <- colnames(data_lar3)[c(6:7,9:18,24:35)]
soleApplicant <- rep(FALSE,nrow(data_lar3))
soleApplicant[grep(TRUE,as.character(data_lar3$co_applicant_race_name_1) == 'No co-applicant')] <- TRUE
blackApplicant <- rep(FALSE,nrow(data_lar3))
blackApplicant[grep(TRUE,as.character(data_lar3$applicant_race_name_1) == 'Black or African American')] <- TRUE
asianApplicant <- rep(FALSE, nrow(data_lar3))
asianApplicant[grep(TRUE,as.character(data_lar3$applicant_race_name_1) == 'Asian')] <- TRUE
otherRaceApplicant <- rep(FALSE,nrow(data_lar3))
otherRaceApplicant[grep(TRUE,sapply(as.character(data_lar3$applicant_race_name_1),function(nm){
  out <- TRUE
  if(nm == 'White'){
    out <- FALSE
  }
  if(nm == 'Black or African American'){
    out <- FALSE
  }
  if(nm == 'Asian'){
    out <- FALSE
  }
  return(out)
}))] <- TRUE

whiteFriend <- rep(FALSE,nrow(data_lar3))
whiteFriend[grep(TRUE,apply(data_lar3[,c('applicant_race_name_1','co_applicant_race_name_1')],2,function(X){
  out <- FALSE 
  if(X[1] != 'White'){
    if(X[2] == 'White'){
      out <- TRUE
    }
  }
}))] <- TRUE

# transform boolean for is male 
isFemale <- data_lar3$applicant_sex - 1

# first lien 
firstLien <- data_lar3$lien_status == 1

# reason other than purchase for loan 
refi <- data_lar3$loan_purpose == 3
homeImprove <- data_lar3$loan_purpose == 2

# loan type non-conventional
FHAinsured <- data_lar3$loan_type == 2
VAguaranteed <- data_lar3$loan_type == 3
FSAguaranteed <- data_lar3$loan_type == 4

# agency variables 
HUD <- data_lar3$agency_code == 7
CreditUnion <- data_lar3$agency_code == 5

# owner occupied 
isOwnerOccupied <- data_lar3$owner_occupancy == 1

# preapproval requested
prereq <- data_lar3$preapproval == 1

# property type 
isManufactured = data_lar3$property_type == 2
isMulti = data_lar3$property_type == 3

data.frame(sum=sapply(as.character(unique(data_lar3$purchaser_type_name)),
         function(nm,data_lar3){
           return(sum(as.character(data_lar3$purchaser_type_name) == nm))
           },data_lar3
         )
)

# a few purchaser types
isFNMA = data_lar3$purchaser_type_name == 'Fannie Mae (FNMA)'
isGNMA = data_lar3$purchaser_type_name == 'Fannie Mae (FNMA)'
isFinComp = data_lar3$purchaser_type_name == 'Life insurance company, credit union, mortgage bank, or finance company'
isFHLMC = data_lar3$purchaser_type_name == 'Freddie Mac (FHLMC)'
isCommercial = data_lar3$purchaser_type_name == 'Commercial bank, savings bank or savings association'
isPrivate = data_lar3$purchaser_type_name == 'Private securitization'
isFAMC = data_lar3$purchaser_type_name == 'Farmer Mac (FAMC)'

# look at income spread to hud median
hudSpread = data_lar3$applicant_income_000s - data_lar3$hud_median_family_income/1000
hudSpreadLog = log(hudSpread+min(hudSpread,na.rm=TRUE)*-1+0.00001, base=10)
hudSpreadLogNormalized = (hudSpreadLog - mean(hudSpreadLog,na.rm=TRUE))/sd(hudSpreadLog,na.rm=TRUE)
IDhudSpreadOutliers <- rep(FALSE, nrow(data_lar3))
IDhudSpreadOutliers[grep(TRUE,abs(hudSpreadLogNormalized) > 5)] <- TRUE
plot(density(hudSpreadLogNormalized[grep(FALSE, IDhudSpreadOutliers)],na.rm=TRUE))

# load amount relative to income
incomeLoanRatio <- data_lar3$loan_amount_000s/data_lar3$applicant_income_000s
incomeLoanRatioLog <- log(incomeLoanRatio, base=10)

# lower density housing
lowDenseArea <- scale(data_lar3$number_of_1_to_4_family_units)
# walk through logic of not making log shapiro wilk goes from .92 -> .99 but would mean 2x transforms...bad trade-off

# self owned
selfOwnedArea <- scale(data_lar3$number_of_owner_occupied_units)

# minority pop
minorityPop <- log(data_lar3$minority_population)

# area total pop
totalAreaPopLog <- log(data_lar3$population,base=10)
# trade off here ... .9 -> .99 but interpretation is easier and don't want second linear transform

# rate spread 
rateSpreadLog <- log(data_lar3$rate_spread,base=10)

# local to area income spread
localIncomeToArea <- scale(data_lar3$tract_to_msamd_income) # discuss not log .94 -> .98 but interpretation down

# build training data
trainData <- data.frame(approved=sapply(data_lar3$action_taken,approvedTransform,successCodes,failCodes),
                        incomeLog=incomeLog,soleApplicant=soleApplicant*1,blackApplicant=blackApplicant*1,
                        asianApplicant=asianApplicant*1, otherRaceApplicant=otherRaceApplicant*1,
                        whiteFriend=whiteFriend*1, isFemale=isFemale, firstLien=firstLien*1, 
                        refinancing=refi*1, homeImprovement=homeImprove*1, isHUD=HUD*1, isCreditUnion=CreditUnion*1, 
                        isOwnerOccupied=isOwnerOccupied*1, isManufactured=isManufactured, isMultiFam=isMulti, 
                        isFNMA=isFNMA*1, isGNMA=isGNMA*1, isFinComp=isFinComp*1, isFHLMC=isFHLMC*1, 
                        isCommercial=isCommercial*1, isPrivate=isPrivate*1,
                        isFAMC=isFAMC*1, hudSpreadLogNormalized=hudSpreadLogNormalized, 
                        incomeLoanRatioLog=incomeLoanRatioLog, lowDenseArea=lowDenseArea, selfOwnedArea=selfOwnedArea,
                        minorityPop=minorityPop,totalAreaPopLog=totalAreaPopLog, rateSpreadLog=rateSpreadLog)

# additions for full mergable set 
mergeSet <- data.frame(asOfYear=data_lar3$as_of_year,respondent_id=data_lar3$respondent_id,
                       county_code=data_lar3$county_code, state_code=data_lar3$state_code,
                       IDhudSpreadOutliers=IDhudSpreadOutliers)

