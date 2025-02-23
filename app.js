const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Welcome to the Cloud Quest! The SECRET_WORD is: CLOUDY');
});

app.get('/docker', (req, res) => {
  res.send('This app is running inside a Docker container!');
});

app.get('/secret_word', (req, res) => {
  const secretWord = process.env.SECRET_WORD || 'SECRET_WORD_NOT_FOUND';
  res.send(`The injected SECRET_WORD is: ${secretWord}`);
});

app.get('/loadbalanced', (req, res) => {
  res.send('This request was load balanced!');
});

// TLS check endpoint
app.get('/tls', (req, res) => {
  if (req.protocol === 'https') {
    res.send('This request was served over HTTPS (TLS).');
  } else {
    res.send('This request was served over HTTP (no TLS).');
  }
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});