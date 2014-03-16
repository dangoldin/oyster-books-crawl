library(ggplot2)
library(scales)
library(ggthemes)
library(reshape)

setwd("/Users/danielgoldin/Dropbox/dev/web/oyster-books-crawl/data")

# Use this to eliminate missing data (where it's set to 0)
non_zero_mean <- function(x) {
  mean(x[x > 0])
}

books <- read.csv("all-books.csv")
books$book_publication_date <- as.Date(books$book_publication_date)
books$book_publication_date_num <- as.numeric(books$book_publication_date)
books$book_publication_year <- as.numeric(format(books$book_publication_date, "%Y"))
books$book_publication_decade <- floor(as.numeric(format(books$book_publication_date, "%Y")) / 10) * 10

books.author <- ddply(books,~book_author,summarise,
  num_books=length(book_author),
  mean_pages=mean(book_number_print_pages),
  earliest_book=min(book_publication_date),
  latest_book=max(book_publication_date),
  mean_rating=non_zero_mean(book_average_rating),
  num_publishers=length(unique(book_publisher_name))
  )

# Distribution of authors by available books
png('oyster-authors-by-num-books.png',width=600, height=600)
ggplot(books.author, aes(x=num_books)) +
  geom_histogram(binwidth=1) +
  theme_few() +
  xlab("# Books Written") + ylab("# of Authors") +
  ggtitle("Distribution of # of authors by # of books")
dev.off()

# Distribution of ratings
png('oyster-authors-author-ratings.png',width=600, height=600)
ggplot(books.author, aes(x=mean_rating)) +
  geom_histogram() +
  theme_few() +
  xlab("Rating") + ylab("Count") +
  ggtitle("Distribution of ratings by author")
dev.off()

books.author.f <- subset(books.author, books.author$num_books > 5)

# Num of books by author
png('oyster-authors-num-books-by-author.png',width=600, height=600)
ggplot(books.author.f,aes(x=reorder(book_author,-num_books), y=num_books)) +
  geom_bar(stat="identity") +
  coord_flip() +
  theme_few() +
  ylab("# of Books") + xlab("Author") +
  ggtitle("# of books by author")
dev.off()

# Most books
head(books.author[order(-books.author$num_books),])

# Most pages
head(books.author[order(-books.author$mean_pages),])

# Best rated
head(books.author[order(-books.author$mean_rating),])

# Worst rated
head(books.author[order(books.author$mean_rating),])

# Earliest book
head(books.author[order(books.author$earliest_book),])

# Last book
tail(books.author[order(books.author$earliest_book),])

png('oyster-authors-box-plot-rating-by-author.png',width=600, height=600)
ggplot(books[books$book_author %in% unique(books.author.f$book_author) & books$book_average_rating > 0, ], aes(x = reorder(book_author, -book_average_rating), y = book_average_rating)) +
  geom_boxplot() +
  theme_few() +
  coord_flip() +
  ylab("Rating") + xlab("Author") +
  ggtitle("Rating by author")
dev.off()

# Author ratings over time
books.filtered <- subset(books, books$book_average_rating > 0 & !is.na(books$book_publication_date))
books.filtered.author <- ddply(books.filtered,~book_author,summarise, num_books=length(book_author))
books.filtered.author.hv <- subset(books.filtered.author, books.filtered.author$num_books > 5)

png('oyster-authors-author-ratings-over-time.png',width=600, height=600)
ggplot(books[books$book_author %in% unique(books.filtered.author.hv$book_author) & books$book_average_rating > 0 & !is.na(books$book_publication_date), ], aes(x = book_publication_date, y = book_average_rating)) +
  geom_line() +
  theme_few() +
  facet_grid(book_author ~ .) +
  theme(strip.text.y = element_text(angle=0)) +
  xlab("Date") + ylab("Rating") +
  ggtitle("Ratings over time")
dev.off()

png('oyster-authors-num-books-vs-rating.png',width=600, height=600)
ggplot(books.author, aes(x=num_books, y=mean_rating)) +
  geom_point() +
  stat_smooth(method="lm", se=TRUE) +
  theme_few() +
  xlab("# Books Written") + ylab("Rating") +
  ggtitle("Rating vs # of books written")
dev.off()

# Publisher
books.publisher <- ddply(books,~book_publisher_name,summarise,
  num_books=length(book_publisher_name),
  mean_pages=mean(book_number_print_pages),
  earliest_book=min(book_publication_date),
  latest_book=max(book_publication_date),
  mean_rating=non_zero_mean(book_average_rating),
  num_authors=length(unique(book_author))
  )

head(books.publisher[order(-books.publisher$num_books),])
tail(books.publisher[order(-books.publisher$num_books),])

head(books.publisher[order(-books.publisher$mean_pages),])

head(books.publisher[order(-books.publisher$mean_rating),])
head(books.publisher[order(books.publisher$mean_rating),])

png('oyster-pub-ratings.png',width=600, height=1200)
ggplot(books[books$book_average_rating > 0, ], aes(x = reorder(book_publisher_name, -book_average_rating), y = book_average_rating)) +
  geom_boxplot() +
  theme_few() +
  coord_flip() +
  ylab("Rating") + xlab("Publisher") +
  ggtitle("Rating by publisher")
dev.off()

# Books by year
books.year <- ddply(books,~book_publication_year,summarise,
  num_books=length(book_author),
  mean_pages=mean(book_number_print_pages),
  earliest_book=min(book_publication_date),
  latest_book=max(book_publication_date),
  mean_rating=non_zero_mean(book_average_rating)
  )

png('oyster-num-pages-by-year.png',width=600, height=600)
ggplot(books.year, aes(x=book_publication_year, y=mean_pages)) +
  geom_bar(stat="identity") +
  theme_few() +
  xlab("Year") + ylab("# of pages") +
  ggtitle("# of pages by year")
dev.off()

# Books by decade
books.decade <- ddply(books,~book_publication_decade,summarise,
  num_books=length(book_author),
  mean_pages=mean(book_number_print_pages),
  earliest_book=min(book_publication_date),
  latest_book=max(book_publication_date),
  mean_rating=non_zero_mean(book_average_rating)
  )

png('oyster-num-pages-by-decade.png',width=600, height=600)
ggplot(books.decade, aes(x=book_publication_decade, y=mean_pages)) +
  geom_bar(stat="identity") +
  theme_few() +
  xlab("Year") + ylab("# of pages") +
  ggtitle("# of pages by decade")
dev.off()

png('oyster-rating-by-decade.png',width=600, height=600)
ggplot(books.decade, aes(x=book_publication_decade, y=mean_rating)) +
  geom_bar(stat="identity") +
  theme_few() +
  xlab("Year") + ylab("Rating") +
  ggtitle("Rating by decade")
dev.off()

# General
png('oyster-rating-vs-pages.png',width=600, height=600)
ggplot(books[books$book_average_rating > 0 & books$book_number_print_pages > 0, ], aes(x=book_number_print_pages, y=book_average_rating)) +
  geom_point() +
  stat_smooth(method="lm", se=TRUE) +
  theme_few() +
  xlab("# of pages") + ylab("Rating") +
  ggtitle("Rating by # of pages")
dev.off()

png('oyster-rating-vs-date.png',width=600, height=600)
ggplot(books[books$book_average_rating > 0 & books$book_publication_date > 0, ], aes(x=book_publication_date, y=book_average_rating)) +
  geom_point() +
  stat_smooth(method="lm", se=TRUE) +
  theme_few() +
  xlab("Publication date") + ylab("Rating") +
  ggtitle("Rating over time")
dev.off()