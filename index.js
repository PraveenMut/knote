// Creating the Note Taking Application to explore k8s.  This contains the main application runtime code.

// dependency requires
const path = require('path');
const MongoClient = require('mongodb').MongoClient;
const express = require('express');
const multer = require('multer');
const marked = require('marked');

const app = express();
const port = process.env.PORT || 3000;
const mongoURL = process.env.MONGO_URL || 'mongodb://localhost:27017/dev';


async function initialiseMongo() {
  console.log('Initialising MongoDB...');
  let success = false;
  while(!success) {
    try {
      client = await MongoClient.connect(mongoURL, { useNewUrlParser: true, useUnifiedTopology: true });
      success = true;
    } catch(e) {
      console.log("There was an error connecting to MongoDB, retrying in 1 second...", e);
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
  }
  console.log('MongoDB has been successfully initialised!');
  return client.db(client.s.options.dbName).collection('notes');
};

const start = async () => {
  // start and listen for MongoDB
  const db = await initialiseMongo();
  // use pug as templating engine
  app.set('view engine', 'pug');
  app.set('views', path.join(__dirname, 'views'));
  app.use(express.static(path.join(__dirname, 'public')));

  app.listen(port, () => {
    console.log(`App listening on http://localhost:${port}`);
  })

  // render index page
  app.get('/', async (req, res) => res.render('index', { notes: await retrieveNotes(db) }));

  app.post(
    '/note',
    multer({ dest: path.join(__dirname, 'public/uploads/') }).single('image'),
    async (req, res) => {
      if (!req.body.upload && req.body.description) {
        await saveNote(db, { description: req.body.description });
        res.redirect('/');
      } else if (req.body.upload && req.file) {
        const link = `/uploads/${encodeURIComponent(req.file.filename)}`;
        res.render('index', {
          content: `${req.body.description} ![](${link})`,
          notes: await retrieveNotes(db),
        })
      }
    },
  )
  
};

const retrieveNotes = async (db) => {
  const notes = (await db.find().toArray()).reverse();
  return notes.map(iter => {
    return {...iter, description: marked(iter.description)};
  });
};

const saveNote = async (db, note) => {
  await db.insertOne(note);
}

start();