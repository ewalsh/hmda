require(quantmod)
require(stringr)
require(RJSONIO)
### LAR data
# get state abbreviation data
StateAbbrData <- read.csv("~/Projects/hmda/Rcode/StateAbbrData.csv")
# create year vector
yrs <- seq(2007,2017,by=1)
# get fips codes to link with names
fips <- read.csv("~/Projects/hmda/data/fips.csv")
# create URL for api
urlBase <- "https://api.consumerfinance.gov/data/hmda/slice/hmda_lar.csv?$where=state_abbr+%3D+'"
urlMiddle <- "'+AND+as_of_year+%3D+"
urlSuffix <- "&$limit=0&$offset=0"
# start with Ohio only
IdOhio <- 36
yrId <- 10
url <- paste(urlBase,as.character(StateAbbrData$Abbreviation[IdOhio]),
             urlMiddle,yrs[yrId],urlSuffix,sep='')
# download
tmpFile <- paste('./data/',as.character(StateAbbrData$Abbreviation[IdOhio]),
                 yrs[10],'lar.csv',sep="")
download.file(url,destfile=tmpFile)
data_lar <- read.csv(tmpFile)

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
censusResults <- data.frame(state_code=NA, state_abbr=NA,county_code=NA, county_name=NA, year=NA, EMP=NA, ESTAB=NA, PAYANN = NA, POP=NA)
cIds <- unique(data_lar[grep(TRUE,as.character(data_lar3$state_abbr) == as.character(StateAbbrData$Abbreviation[IdOhio])),'county_code'])
cIds <- cIds[grep(TRUE,!is.na(cIds))]
#print("https://api.census.gov/data/2017/cbp?get=NAICS2017_LABEL,NAICS2017,GEO_ID,LFO,LFO_LABEL,EMPSZES_LABEL,EMPSZES,EMP&for=county:*&in=state:*&key=YOUR_KEY_GOES_HERE")

apiKey <- Sys.getenv('CENSUS_API') ## replace with your own key
urlBase <- "https://api.census.gov/data/2017"
urlMiddle <- "/cbp?get=COUNTY,EMP,EMPSZES,EMPSZES_LABEL,ESTAB,NAICS2017,NAICS2017_LABEL,PAYANN,STATE,YEAR&for=county:"
# tmpFile <- paste('./data/',as.character(StateAbbrData$Abbreviation[IdOhio]),
#                  yrs[10],'county',cIds[1],'census','.json',sep="")
tmpFile <- './data/tmpCensus.json'
for(i in 1:length(cIds)){
  cIdStr = as.character(cIds[i])
  if(str_length(cIdStr) < 3){
    cIdStr <- paste(paste(rep('0',3-str_length(cIdStr)),collapse=''),cIdStr,sep='')
  }
  download.file(paste(urlBase,urlMiddle,cIdStr,"&in=state:",as.character(data_lar3$state_code[1]),"&key=",apiKey,sep=""),
                destfile=tmpFile) # removed dynamic year from now yrs[10]-2
  censusData <- fromJSON(tmpFile)
  censusData.df <- data.frame(matrix(sapply(2:length(censusData),function(iter,censusData){
    return((censusData[[iter]]))
  },censusData),nrow=length(censusData)-1,byrow=TRUE),stringsAsFactors=FALSE)
  colnames(censusData.df) <- censusData[[1]]
  # all establishments only 
  censusData.df <- censusData.df[grep(TRUE,as.character(unlist(censusData.df$EMPSZES)) == "001"),]
  
  censusSums <- apply(censusData.df[,c("EMP","ESTAB","PAYANN")],2,function(X){sum(unlist(as.numeric(X)),na.rm=TRUE)})
  # find county info
  subFIPS1 = fips[grep(TRUE,fips$State.Code..FIPS. == as.numeric(as.character(data_lar3$state_code[1]))),]
  subFIPS2 = subFIPS1[grep(TRUE, subFIPS1$County.Code..FIPS. == cIds[i]),]
  cNm = subFIPS2[grep(TRUE,subFIPS2$County.Subdivision.Code..FIPS. == 0), ncol(subFIPS2)]
  
  # find pop
  #print("https://api.census.gov/data/2010/dec/sf1?get=H001001,NAME&for=state:*&key=[user key]")
  popLink <- paste("https://api.census.gov/data/2010/dec/sf1?get=H010001,NAME&for=county:",cIdStr,"&in=state:",
                   as.character(data_lar3$state_code[1]),"&key=",apiKey,sep="")
  download.file(popLink,destfile = './data/tmpPop.json')
  popData <- fromJSON('./data/tmpPop.json')
  
  tmp <- data.frame(state_code=as.numeric(as.character(data_lar3$state_code[1])),
                    state_abbr=as.character(StateAbbrData$Abbreviation[IdOhio]),
                    county_code=cIds[i], county_name=cNm, year=2017, EMP=censusSums['EMP'], ESTAB=censusSums['ESTAB'],
                    PAYANN = censusSums['PAYANN'], POP=as.numeric(popData[[2]][1]))
  censusResults <- rbind(censusResults,tmp)
}
censusResults <- censusResults[-1, ]



## INSTITUTIONS
urlBase <- "https://api.consumerfinance.gov/data/hmda/slice/institutions.csv?$where=respondent_state+%3D+'"
urlMiddle <- "'+AND+activity_year+%3D+"
urlSuffix <- "'&$limit=0&$offset=0"
# start with Ohio only
IdOhio <- 36
url <- paste(urlBase,as.character(StateAbbrData$Abbreviation[IdOhio]),
             urlSuffix,sep='') # urlMiddle,yrs[10],
# download
tmpFile <- paste('./data/',as.character(StateAbbrData$Abbreviation[IdOhio]),
                 yrs[10],'insts.csv',sep="")
download.file(url,destfile=tmpFile)
data_inst <- read.csv(tmpFile)

## ECONOMIC DATA
# delinquency rate on single family residential mortgages
DRSFRMACBS = data.frame(getSymbols("DRSFRMACBS",src="FRED",auto.assign=FALSE))
diffLogData <- diff(log(DRSFRMACBS[,1]))
normDelinq <- data.frame(DelinquencyRate=(diffLogData-mean(diffLogData))/sd(diffLogData),
                         row.names=row.names(DRSFRMACBS)[-1])
# find year and month/quarter
normDelinq <- data.frame(value=normDelinq$DelinquencyRate,
                         year=as.numeric(str_sub(row.names(normDelinq),1,4)),
                         month=as.numeric(str_sub(row.names(normDelinq),6,7)),
                         type=rep('delinquency_rate',nrow(normDelinq)),
                         date=row.names(normDelinq))

# mortgage debt outstanding
MDOAH = data.frame(getSymbols("MDOAH",src="FRED",auto.assign=FALSE))
diffLogData <- diff(log(MDOAH[,1]))
mortDebtOut <- data.frame(MortDebtOut=(diffLogData-mean(diffLogData,na.rm=TRUE))/sd(diffLogData,na.rm=TRUE),
                         row.names=row.names(MDOAH)[-1])
# find year and month/quarter
mortDebtOut <- data.frame(value=mortDebtOut$MortDebtOut,
                          year=as.numeric(str_sub(row.names(mortDebtOut),1,4)),
                          month=as.numeric(str_sub(row.names(mortDebtOut),6,7)),
                          type=rep('mort_debt_out',nrow(mortDebtOut)),
                          date=row.names(mortDebtOut))
  
# net percentage of domestic banks tightening standards for auto loans
STDSAUTO = data.frame(getSymbols("STDSAUTO",src="FRED",auto.assign=FALSE))

# find year and month/quarter
autoStandards <- data.frame(value=STDSAUTO$STDSAUTO,
                            year=as.numeric(str_sub(row.names(STDSAUTO),1,4)),
                            month=as.numeric(str_sub(row.names(STDSAUTO),6,7)),
                            type=rep('auto_standards',nrow(STDSAUTO)),
                            date=row.names(STDSAUTO))
  

# make CPI deflator 
## Inflation -- CPI
CPIAUCSL = data.frame(getSymbols("CPIAUCSL", src="FRED",auto.assign=FALSE))
deflator <- data.frame(value=CPIAUCSL$CPIAUCSL/CPIAUCSL$CPIAUCSL[nrow(CPIAUCSL)],
                       year=as.numeric(str_sub(row.names(CPIAUCSL),1,4)),
                       month=as.numeric(str_sub(row.names(CPIAUCSL),6,7)),
                       type=rep("deflator",nrow(CPIAUCSL)),
                       date=row.names(CPIAUCSL))

fred <- rbind(normDelinq,mortDebtOut,autoStandards,deflator)