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
incomeCDFfunc <- ecdf(data_lar3$applicant_income_000s)

# build training data
trainData <- data.frame(approved=sapply(data_lar3$action_taken,approvedTransform,successCodes,failCodes),
                        incomeCDF=incomeCDFfunc(data_lar3$applicant_income_000s))