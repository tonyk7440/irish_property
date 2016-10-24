# Capture Data from daft.ie

# Load libraries
library(rvest)
library(stringr)
library(tidyr)
library(rpart)


# Initialise empty data frame
property <- data.frame()
links <- c()

i <- 0

while(i < 100) {
    if( i < 10) {
        stub <- c("http://www.daft.ie/ireland/property-for-sale/?s%5Bsort_by%5D=date&s%5Bsort_type%5D=d")
        html <- read_html(stub)
        cast <- html_nodes(html,".box") %>% 
            html_text(trim=TRUE) %>% ifelse(. == "", NA, .) %>%
            str_trim()
        #cast[1] <- paste("1. \n \n ", cast[1])
    }
    else{
        stub <- c("http://www.daft.ie/ireland/property-for-sale/?s%5Bsort_by%5D=date&s%5Bsort_type%5D=d&offset=")
        link <- paste(stub,i, sep = "")
        print(paste("Visiting Link: ", link))
        html <- read_html(link)
        cast <- html_nodes(html,".box") %>% 
            html_text(trim=TRUE) %>% ifelse(. == "", NA, .) %>%
            str_trim()
    }
    nawhite <- str_replace(cast, "-", "\n")
    nawhite <- str_replace_all(nawhite, "\\|", "")
    nawhite <- str_replace_all(nawhite, "Agent: ", "")
    curr <- as.data.frame(str_split_fixed(nawhite, "\n", n = 50))
    property <- rbind(property, curr)
    
    # Deal with links
    pg <- html_nodes(html,"#sr_content .truncate a , .info li, .price, .search_result_title_box a, .date_entered") %>% html_attr("href")
    pg[pg=="/building-energy-rating-ber"] <- NA
    linksB <- pg[!is.na(pg)]
    links <- c(links,linksB)
    i <- i + 10
}

links_df <- data.frame()
n <- 1
entry <- TRUE
for(j in 1:length(links)) {
    if( substr(links[j], 1,1) =="/") {
        ifelse(entry == TRUE, n <- n, n <- n+1)
        links_df[n,1] <- links[j]   
        entry <- FALSE
    }
    else{
        links_df[n,2] <- links[j]
        n <- n+1
        entry <- TRUE
    }
}

# Change relative url's to absolute
links_df$url <- paste("www.daft.ie", links_df$V1, sep = "")

# Extract estate agent
links_df$agent <- basename(links_df$V2)

# Remove old columns
links_df$V1 <- NULL
links_df$V2 <- NULL

# Convert every cell to character type
property_char <- as.data.frame(lapply(property, as.character))

# Trim white space to empty cells
property_char[] <- lapply(property_char, trimws)
# Replace empty cells with NA values
property_char[property_char==""] <- NA


# Replace un-needed values with na
for (i in 1:ncol(property_char)) {
    hits <- grep(pattern = "BER|     |Learn|Photos|Photo|Energy|scale|lower|Add", x = property_char[,i])
    property_char[,i][hits] <- NA
    i = i + 1 
}

# Delete every NA value, shifting cells to the left
property_char = as.data.frame(t(apply(property_char,1, function(x) { return(c(x[!is.na(x)],x[is.na(x)]) )} )))
# Convert every cell to character type
property_char[] <- lapply(property_char, as.character)

# Separate address
props <- separate(property_char, V2, c("AddressOne", "AddressTwo", "AddressThree", "AddressFour", "AddressFive", "AddressSix"), sep = ",", remove = TRUE, fill = "left")

# Remove id column
props$V1 <- NULL
colnames(props) <- c("AddressOne", "AddressTwo", "AddressThree", "AddressFour", "AddressFive", "AddressSix", "Type", "Photos", "Price", "Type2", "Beds", "Baths", "Other")
# Remove rows with all na's
prop <- props[rowSums(is.na(props)) != ncol(props),]

# Combine property info and url links data frames
prop <- cbind(prop, links_df)

# Remove land and sites for sale
hits <- grep(pattern = "Site For Sale", x = prop$Type)
land <- prop[hits,]
homes <- prop[-hits,]

# Remove punctuation from price
homes$Price <- gsub(",|\u20AC", "", homes$Price)

# Remove rows with no price or wrongly formatted
alpha_hits <- grep(pattern = "[[:alpha:]]", x = homes$Price)
#hitsB <- grep(pattern = "[[:punct:]]", x = homes$Photos)
noPrice <- homes[alpha_hits,]
clean <- homes[-alpha_hits,]

# Get price change details
hits <- grep(pattern = "[[:digit:]]", x = clean$Type2)

clean$priceChange <- NA

# Populate priceChange column
if(length(hits) > 0) {
    for(i in 1:length(hits)) {
        # Get 
        change <- clean$Type2[hits[i]]
        clean$Type2[hits[i]] <- NA
        clean[hits[i],10:(ncol(clean)-4)] <- clean[hits[i],11:(ncol(clean)-3)]
        clean$priceChange[hits[i]] <- change
    }
}

# Clean up beds column
clean$Beds <- str_replace_all(clean$Beds, " Beds| Bed", "")

# Clean up baths column
clean$Baths <- str_replace_all(clean$Baths, " Baths|Bath", "")

# Remove bad text from baths column
hits <- grep(pattern = "[[:alpha:]]", x = clean$Baths)
clean$Baths[hits] <- NA

# Clean Type Column, shorten descriptions
clean$Type <- str_replace_all(clean$Type, " For Sale| House", "")

clean <- clean %>% drop_na(Price)

# Change column types
clean$AddressFive <- as.factor(clean$AddressFive)
clean$AddressSix <- as.factor(clean$AddressSix)
clean$Type <- as.factor(clean$Type)
clean$Photos <- as.numeric(clean$Photos)
clean$Price <- as.numeric(clean$Price)
clean$Beds <- as.numeric(clean$Beds)
clean$Baths <- as.numeric(clean$Baths)
clean$agent <- as.factor(clean$agent)

# Use decision tree to predict NA bathrooms    
Tree <- rpart(Baths ~ AddressFive + Price + Beds, 
              data=clean[!is.na(clean$Baths),])

#Impute Predictions into dataset
clean$Baths[is.na(clean$Baths)] <- predict(Tree, clean[is.na(clean$Baths),])

# Round Baths column
clean$Baths <- round(clean$Baths,0)

# Clean price change column
clean$priceChange <- gsub(",|\u20AC", "", clean$priceChange)
clean$priceChange[is.na(clean$priceChange)] <- 0

# Remove duplicate type2 column
clean$Type2 <- NULL

# Trim to useful information
trimmed <- clean[,-c(12:53)]


# Drop columns non-essential for app
final <- subset(trimmed, select=-c(AddressOne, AddressTwo, AddressThree, priceChange))


# Write data to file
write.csv(final, "input/properties.csv", row.names = FALSE)
