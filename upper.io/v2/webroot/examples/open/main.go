package main

import (
	"log"

	"upper.io/db.v2"            // Imports the main db package.
	"upper.io/db.v2/postgresql" // Imports the postgresql adapter.
)

// Book represents a book.
type Book struct {
	ID        int    `db:"id"`
	Title     string `db:"title"`
	AuthorID  int    `db:"author_id"`
	SubjectID int    `db:"subject_id"`
}

var settings = postgresql.ConnectionURL{
	Database: `booktown`, // Database name.
	Address:  db.ParseAddress(`demo.upper.io`),
	User:     `demouser`, // Database username.
	Password: `demop4ss`, // Database password.
}

func main() {
	sess, err := db.Open("postgresql", settings)
	if err != nil {
		log.Fatal(err)
	}

	defer sess.Close()

	col, err := sess.Collection("books")
	if err != nil {
		log.Fatal(err)
	}

	// Get all books sorted by their id column.
	req := col.Find().Sort("id") // Tip: Try to use "-id"

	var books []Book
	if err := req.All(&books); err != nil {
		log.Fatal(err)
	}

	for _, book := range books {
		log.Printf("%#v\n", book)
	}
}
