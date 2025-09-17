



## Check all species added BY SITE
sp_count_site <- paste0("SELECT DISTINCT Ancestry, SiteID, PK_Species, Species.NewSynonym as 'Updated Code', SpeciesName, CommonName, SpeciesQualifier, Count(PK_Species)  from Protocol
  INNER JOIN EventGroup ON EventGroup.FK_Protocol = Protocol.PK_Protocol
  INNER JOIN Event ON Event.FK_EventGroup = EventGroup.PK_EventGroup
  INNER JOIN Site ON Site.PK_Site = Event.FK_Site
  INNER JOIN AncestryCombinedPath ON AncestryCombinedPath.PK_Site = Site.PK_Site
  INNER JOIN Sample ON Sample.FK_Event = Event.PK_Event
  INNER JOIN Species ON Species.PK_Species = Sample.FK_Species
  where List = 'NRCS' and eventName LIKE '%Frequency%'
  group by Ancestry, SiteID, PK_Species, 'Updated Code', SpeciesName, CommonName, SpeciesQualifier
  order by Ancestry, SiteID, SpeciesName, PK_Species")

speciesCheck_site <- dbGetQuery(mydb, sp_count_site)
#View(speciesCheck)

file_name <- paste0("data/speciesView_Site_",gsub("-","_",substr(Sys.time(),1,19)),".csv")
file_name_cleaning <- gsub(":","",file_name)
file_name_clean <- gsub(" ","_",file_name_cleaning)

write.csv(speciesCheck_site, file_name_clean, row.names = FALSE)
shell.exec(paste0(getwd(),"/",file_name_clean))

## Check all species added BY SITE
sp_count_byDownload <- paste0("SELECT DISTINCT PK_Species, Species.NewSynonym as 'Updated Code', SpeciesName, CommonName, SpeciesQualifier, Count(PK_Species)  from Protocol
  INNER JOIN EventGroup ON EventGroup.FK_Protocol = Protocol.PK_Protocol
  INNER JOIN Event ON Event.FK_EventGroup = EventGroup.PK_EventGroup
  INNER JOIN Site ON Site.PK_Site = Event.FK_Site
  INNER JOIN AncestryCombinedPath ON AncestryCombinedPath.PK_Site = Site.PK_Site
  INNER JOIN Sample ON Sample.FK_Event = Event.PK_Event
  INNER JOIN Species ON Species.PK_Species = Sample.FK_Species
  where List = 'NRCS' and eventName LIKE '%Frequency%'
  group by PK_Species, 'Updated Code', SpeciesName, CommonName, SpeciesQualifier
  order by SpeciesName, PK_Species")

speciesCheck_byDownload <- dbGetQuery(mydb, sp_count_byDownload)
#View(speciesCheck)

file_name <- paste0("data/speciesView_byDownload_",gsub("-","_",substr(Sys.time(),1,19)),".csv")
file_name_cleaning <- gsub(":","",file_name)
file_name_clean <- gsub(" ","_",file_name_cleaning)

write.csv(speciesCheck_byDownload, file_name_clean, row.names = FALSE)
shell.exec(paste0(getwd(),"/",file_name_clean))

#dbDisconnect(mydb)
