require(quantmod)
require(stringr)
### LAR data
# get state abbreviation data
StateAbbrData <- read.csv("~/Projects/hmda/Rcode/StateAbbrData.csv")
# create year vector
yrs <- seq(2007,2017,by=1)
# create URL for api
urlBase <- "https://api.consumerfinance.gov/data/hmda/slice/hmda_lar.csv?$where=state_abbr+%3D+'"
urlMiddle <- "'+AND+as_of_year+%3D+"
urlSuffix <- "&$limit=0&$offset=0"
# start with Ohio only
IdOhio <- 36
url <- paste(urlBase,as.character(StateAbbrData$Abbreviation[IdOhio]),
             urlMiddle,yrs[10],urlSuffix,sep='')
# download
tmpFile <- paste('./data/load/',as.character(StateAbbrData$Abbreviation[IdOhio]),
                 yrs[10],'lar.csv',sep="")
download.file(url,destfile=tmpFile)
data_lar <- read.csv(tmpFile)
# replace NA with NULL
apply(data_lar,2,function(X){
  length(grep(TRUE,is.na(X)))
  # if(length(grep(TRUE,is.na(X))) > 0){
  #   X[grep(TRUE,is.na(X))] <- NULL
  # }
})
# drop applicant income NA 
write.csv(data_lar[grep(FALSE,is.na(data_lar$applicant_income_000s)),],
          tmpFile,row.names=FALSE)
## CENSUS TRACTS -- NOT USEFUL
# urlBase <- "https://api.consumerfinance.gov/data/hmda/slice/census_tracts.csv?$where=state_code+%3D+"
# urlMiddle <- "+AND+as_of_year+%3D+"
# urlSuffix <- "&$limit=0&$offset=0"
# # start with Ohio only
# IdOhio <- 36
# url <- paste(urlBase,as.character(StateAbbrData$Abbreviation[IdOhio]),
#              urlMiddle,yrs[10],urlSuffix,sep='')
# # download
# tmpFile <- paste('./data/',as.character(StateAbbrData$Abbreviation[IdOhio]),
#                  yrs[10],'.csv',sep="")
# download.file(url,destfile=tmpFile)
# data <- read.csv(tmpFile)

## CENSUS BUREAU 
apiKey <- Sys.getEnv('CENSUS_API') ## replace with your own key
urlBase <- "https://api.census.gov/data/"
urlMiddle <- "/cbp?get=COUNTY,CSA,EMP,EMP_N,EMPSZES,ESTAB,GEO_ID,GEOTYPE,LFO,MD,MSA,NAICS2012,PAYANN,PAYANN_N,ST,YEAR&for=state:"
tmpFile <- paste('./data/',as.character(StateAbbrData$Abbreviation[IdOhio]),
                 yrs[10],'census','.json',sep="")
download.file(paste(urlBase,yrs[10],urlMiddle,as.character(data$state_code[1]),sep=""),
              destfile=tmpFile)
censusData <- fromJSON(tmpFile)
censusData.df <- data.frame(matrix(sapply(2:length(censusData),function(iter,censusData){
  return((censusData[[iter]]))
  },censusData),nrow=length(censusData)-1,byrow=TRUE),stringsAsFactors=FALSE)
colnames(censusData.df) <- censusData[[1]]

## INSTITUTIONS
urlBase <- "https://api.consumerfinance.gov/data/hmda/slice/institutions.csv?$where=respondent_state+%3D+'"
urlMiddle <- "'+AND+activity_year+%3D+"
urlSuffix <- "&$limit=0&$offset=0"
# start with Ohio only
IdOhio <- 36
url <- paste(urlBase,as.character(StateAbbrData$Abbreviation[IdOhio]),
             urlMiddle,yrs[10],urlSuffix,sep='')
# download
tmpFile <- paste('./data/',as.character(StateAbbrData$Abbreviation[IdOhio]),
                 yrs[10],'insts.csv',sep="")
download.file(url,destfile=tmpFile)
data <- read.csv(tmpFile)

## ECONOMIC DATA
# delinquency rate on single family residential mortgages
DRSFRMACBS = data.frame(getSymbols("DRSFRMACBS",src="FRED",auto.assign=FALSE))
diffLogData <- diff(log(DRSFRMACBS[,1]))
normDelinq <- data.frame(DelinquencyRate=(diffLogData-mean(diffLogData))/sd(diffLogData),
                         row.names=row.names(DRSFRMACBS)[-1])
# find year and month/quarter
normDelinq <- cbind(normDelinq,data.frame(year=as.numeric(str_sub(row.names(normDelinq),1,4)),
                                          month=as.numeric(str_sub(row.names(normDelinq),6,7)),
                                          type=rep('delinquency_rate',nrow(normDelinq)))
)
# mortgage debt outstanding
MDOAH = data.frame(getSymbols("MDOAH",src="FRED",auto.assign=FALSE))
diffLogData <- diff(log(MDOAH[,1]))
mortDebtOut <- data.frame(MortDebtOut=(diffLogData-mean(diffLogData,na.rm=TRUE))/sd(diffLogData,na.rm=TRUE),
                         row.names=row.names(MDOAH)[-1])
# find year and month/quarter
mortDebtOut <- cbind(mortDebtOut,data.frame(year=as.numeric(str_sub(row.names(mortDebtOut),1,4)),
                                          month=as.numeric(str_sub(row.names(mortDebtOut),6,7)),
                                          type=rep('mort_debt_out',nrow(mortDebtOut)))
)
# net percentage of domestic banks tightening standards for auto loans
STDSAUTO = data.frame(getSymbols("STDSAUTO",src="FRED",auto.assign=FALSE))

# find year and month/quarter
autoStandards <- cbind(STDSAUTO,data.frame(year=as.numeric(str_sub(row.names(STDSAUTO),1,4)),
                                          month=as.numeric(str_sub(row.names(STDSAUTO),6,7)),
                                          type=rep('auto_standards',nrow(STDSAUTO)))
)
