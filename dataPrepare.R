library(Tushare)
library(lubridate)
ts_token <- "1d16578e52e6e9e1fb16ba9405fa11223e621a1889b5cda2d4d4cf91"
api <- pro_api(token = ts_token)
stock_basic <- api(api_name="stock_basic")

# 数据库
library(DBI)
# Create an ephemeral in-memory RSQLite database
con <- dbConnect(RSQLite::SQLite(), "stock.sqlite3")

dbWriteTable(con, "stock_basic", stock_basic)
dbListTables(con)
dbDisconnect(con)

ts_code <- stock_basic$ts_code[1]
dayInterval = 1095
end_date <- as.character(format(today(),"%Y%m%d"))
start_date <- as.character(format(today()-days(dayInterval),"%Y%m%d"))
df <- api(api_name = 'daily', ts_code = ts_code, start_date = start_date, end_date = end_date) 
df$trade_date <- ymd(df$trade_date)


library(DBI)
# Create an ephemeral in-memory RSQLite database
con <- dbConnect(RSQLite::SQLite(), "stock.sqlite3")
for(i in 1:nrow(stock_basic)){
  ts_code <- stock_basic$ts_code[i]
  dayInterval = 1095
  end_date <- as.character(format(today(),"%Y%m%d"))
  start_date <- as.character(format(today()-days(dayInterval),"%Y%m%d"))
  df <- try(api(api_name = 'daily', ts_code = ts_code, start_date = start_date, end_date = end_date))
  if(inherits(df,"try-error")){
    cat(i,"\n",file = "error.txt",append = T)
  } else{
    df$trade_date <- ymd(df$trade_date)
    dbWriteTable(con, "daily", df, append = T)
    cat(i,"\n")
    Sys.sleep(1)
  }
}
dbDisconnect(con)