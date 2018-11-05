import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPageState extends State<LoginPage> {

  final GlobalKey<FormState> _formState = new GlobalKey<FormState>();

  String _email;
  String _password;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Demo Taller'),
      ),
      body: _createBody(),
      backgroundColor: Colors.white,
    );
  }

  Widget _createBody() {
    return new Container(
      padding: new EdgeInsets.only(top: 10.0),
      child: _createLoginView(),
    );
  }

  Widget _createLoginView() {
    return new Form(
      key: this._formState,
      child: new ListView(
        children: <Widget>[
          new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.asset('images/flutter.png'),
              new TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: new InputDecoration(
                    hintText: 'Ingrese su usuario',
                    labelText: 'Direccion E-mail',
                    icon: new IconButton(icon: const Icon(Icons.mail))
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Debe ingresar su usuario!';
                  }
                },
                onSaved: (value) => _email = value,
              ),
              new TextFormField(
                decoration: new InputDecoration(
                    hintText: 'Contraseña',
                    labelText: 'Ingrese su contraseña',
                    icon: new IconButton(icon: const Icon(Icons.lock))
                ),
                obscureText: true,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Debe ingresar su contraseña!';
                  }
                },
                onSaved: (value) => _password = value,
              )
            ],
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new RaisedButton(
                onPressed: _pushLogin,
                textColor: Colors.white,
                color: Colors.black,
                padding: new EdgeInsets.all(8.0),
                child: new Text('Login'),
              )
            ],
          ),
        ],
      ),
    );
  }

  void _pushLogin() {
    if (_formState.currentState.validate()) {
      this._formState.currentState.save();
      _handleSignIn()
          .then((FirebaseUser user) => _navigateToHome())
      .catchError((e) => print(e));
    }
  }

  Widget _navigateToHome() {
    Navigator.of(context).push(
        new MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return new HomePage();
          }
        )
    );
  }

  Future<FirebaseUser> _handleSignIn() async {
    FirebaseUser user = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: _email, password: _password);
    return user;
  }
}

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => new LoginPageState();
}

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List data;

  Future<String> getData() async {
    var response = await http.get(
        Uri.encodeFull("https://restcountries.eu/rest/v2/regionalbloc/usan"),
        headers: {"Accept": "application/json"});

    this.setState(() {
      data = json.decode(response.body);
    });

    return "Success!";
  }

  @override
  void initState() {
    super.initState();
    this.getData();
  }

  navigateToDetail(Country country) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => DetailPage(country: country)));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Taller Countries"),
        actions: <Widget>[
          new IconButton(icon: const Icon(Icons.highlight_off), onPressed: _onLogout),
        ],
      ),
      body: _buildCountries(),
    );
  }

  Future<Widget> _onLogout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        new MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return new LoginPage();
            }
        ),
            (Route<dynamic> route) => false
    );
  }

  Widget _buildCountries() {
    return ListView.builder(
        itemCount: data == null ? 0 : data.length,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          return ListTile(
            title: Text(data[i]["name"]),
            onTap: () => navigateToDetail(
                  Country(
                    name: data[i]["name"],
                    capital: data[i]["capital"],
                    population: data[i]["population"],
                    currency: data[i]["name"],
                    area: data[i]["area"],
                    gini: data[i]["gini"],
                    latitude: data[i]["latlng"][0],
                    longitude: data[i]["latlng"][1],
                    url: data[i]["flag"],
                  ),
                ),
          );
        });
  }
}

class Country {
  final String name;
  final String capital;
  final int population;
  final String currency;
  final double area;
  final double gini;
  final double latitude;
  final double longitude;
  final String url;

  const Country(
      {this.name,
      this.capital,
      this.population,
      this.currency,
      this.area,
      this.gini,
      this.latitude,
      this.longitude,
      this.url});
}

class DetailPage extends StatefulWidget {
  final Country country;

  DetailPage({this.country});

  @override
  DetailPageState createState() => DetailPageState();
}

class DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text("Detalle País"),
        ),
        body: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text("País: " + widget.country.name),
              ],
            ),
            Row(
              children: <Widget>[
                Text("Capital: " + widget.country.capital),
              ],
            ),
            Row(
              children: <Widget>[
                Text("Poblacion: " + widget.country.population.toString()),
              ],
            ),
            Row(
              children: <Widget>[
                Text("Moneda: " + widget.country.currency),
              ],
            ),
            Row(
              children: <Widget>[
                Text("Area: " + widget.country.area.toString()),
              ],
            ),
            Row(
              children: <Widget>[
                Text("Indice Gini: " + widget.country.gini.toString()),
              ],
            ),
            Row(
              children: <Widget>[
                Text("Latitud: " + widget.country.latitude.toString()),
              ],
            ),
            Row(
              children: <Widget>[
                Text("Longitud: " + widget.country.longitude.toString()),
              ],
            ),
            Row(
              children: <Widget>[
                new SvgPicture.network(
                  widget.country.url,
                  width: 150.0,
                ),
              ],
            ),
          ],
        ));
  }
}
