import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;


// Variables globales para controlar el estado visual en toda la app de forma sencilla
final ValueNotifier<ThemeMode> modoTemaNotificador = ValueNotifier(ThemeMode.light);
final ValueNotifier<double> escalaTextoNotificador = ValueNotifier(1.0);

void main() {
  runApp(const MiAppEstudiante());
}

class MiAppEstudiante extends StatelessWidget {
  const MiAppEstudiante({super.key});

  @override
  Widget build(BuildContext context) {
    const Color naranjaUP = Color(0xFFFF8200);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: modoTemaNotificador,
      builder: (context, ThemeMode modoActual, child) {
        return ValueListenableBuilder<double>(
          valueListenable: escalaTextoNotificador,
          builder: (context, double escalaTexto, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'UP-APP',
              themeMode: modoActual, 
              // --- TEMA CLARO ---
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: naranjaUP,
                  primary: naranjaUP,
                  brightness: Brightness.light,
                  surface: const Color(0xFFF5F5F5), // Fondo gris claro
                ),
                appBarTheme: const AppBarTheme(
                  backgroundColor: naranjaUP,
                  foregroundColor: Colors.white,
                  elevation: 2,
                ),
                cardColor: Colors.white, 
              ),
              // --- TEMA OSCURO ---
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: naranjaUP,
                  primary: naranjaUP,
                  brightness: Brightness.dark,
                  surface: const Color(0xFF121212), // Fondo gris oscuro
                ),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFF212121), // Colors.grey[900]
                  foregroundColor: naranjaUP,
                  elevation: 2,
                ),
                cardColor: const Color(0xFF303030), 
              ),
              // Escalado dinámico de texto para la accesibilidad
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(escalaTexto)),
                  child: child!,
                );
              },
              home: const PantallaLogin(),
            );
          },
        );
      },
    );
  }
}

// ==========================================================
// 0. NUEVA PANTALLA: LOGIN (Inicio de Sesión)
// ==========================================================
class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 1. Variable para controlar la ruedita de carga
  bool _estaCargando = false;

  // 2. Función para mostrar el error flotante (estilo Material 3)
  void _mostrarMensajeError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // 3. Función para conectar con la API
  Future<void> _iniciarSesion(String matricula, String password) async {
    // Si los campos están vacíos, no hacemos la petición
    if (matricula.isEmpty || password.isEmpty) {
      _mostrarMensajeError('Por favor, ingresa tu matrícula y contraseña.');
      return;
    }

    setState(() { _estaCargando = true; });

    try {
      final baseUrl = 'http://sip.upnl.edu.mx/alumnos.php';
      final urlSignin = Uri.parse('$baseUrl/signin');

      // 1. Petición GET inicial: obtenemos la cookie de sesión temporal
      //    y el token CSRF que viene oculto en el formulario HTML.
      final respuestaInicial = await http.get(urlSignin);

      final cookieInicial = respuestaInicial.headers['set-cookie']?.split(';').first;
      if (cookieInicial == null) {
        _mostrarMensajeError('No se pudo iniciar sesión con el servidor.');
        return;
      }

      final documento = html_parser.parse(respuestaInicial.body);
      final csrfInput = documento.querySelector('input[name="signin[_csrf_token]"]');
      final csrfToken = csrfInput?.attributes['value'];

      if (csrfToken == null) {
        _mostrarMensajeError('No se pudo iniciar sesión con el servidor.');
        return;
      }

      // 2. Petición POST con las credenciales reales, la cookie inicial
      //    y el token CSRF (tal como lo hace el navegador).
      final respuesta = await http.post(
        urlSignin,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Cookie': cookieInicial,
        },
        body: {
          'signin[_csrf_token]': csrfToken,
          'signin[tipo_usuario]': '1',
          'signin[username]': matricula,
          'signin[password]': password,
        },
      );

      // 3. Un login CORRECTO responde 302 y redirige a alumnos.php/
      //    (no a alumnos.php/signin de nuevo). Además, entrega una
      //    cookie de sesión NUEVA (distinta a la inicial).
      final location = respuesta.headers['location'] ?? '';
      final cookieNueva = respuesta.headers['set-cookie']?.split(';').first;

      final loginExitoso = respuesta.statusCode == 302 &&
          !location.contains('signin') &&
          cookieNueva != null;

      if (loginExitoso) {
        // Guarda la cookie de sesión para usarla en las siguientes peticiones
        // (consultar calificaciones, becas, etc). Recomendado: flutter_secure_storage.
        // await storage.write(key: 'session_cookie', value: cookieNueva);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MenuPrincipal()),
        );
      } else {
        _mostrarMensajeError('Matrícula o contraseña incorrectos.');
      }
    } catch (e) {
      _mostrarMensajeError('Error de conexión. Revisa tu internet.');
    } finally {
      setState(() { _estaCargando = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color naranjaUP = Color(0xFFFF8200);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text('SISTEMA INTEGRAL DE INFORMACIÓN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text('COMUNIDAD ESTUDIANTIL', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // BANNER DEL LOGO (Modificado: Se quitaron los íconos de simulación)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                  decoration: BoxDecoration(
                    color: naranjaUP,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center( // Ahora solo centramos el texto
                    child: Text(
                      'UNIVERSIDAD\nPOLITÉCNICA\nDE APODACA',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), // Un poco más grande para mejor presencia al estar solo
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                              
                              const SizedBox(height: 40),

                              // TEXTO DE BIENVENIDA
                              const Text(
                                'Bienvenido a la Comunidad\nEstudiantil',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
              
              const SizedBox(height: 40),

              // CUADRO NARANJA DEL FORMULARIO
              Container(
                padding: const EdgeInsets.all(25.0),
                decoration: BoxDecoration(
                  color: naranjaUP,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Matrícula', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _matriculaController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFD9D9D9), // Gris claro exacto de la imagen
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0), // Bordes cuadrados como en la foto
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    const Text('Contraseña:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _passwordController,
                      obscureText: true, // Oculta el texto de la contraseña
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFD9D9D9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    Center(
                      child: ElevatedButton(
                        // Si está cargando, ponemos null para deshabilitar el botón
                        onPressed: _estaCargando
                            ? null
                            : () {
                                // Llamamos a nuestra nueva función
                                _iniciarSesion(
                                  _matriculaController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8EAF6),
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        // Cambiamos el texto por una ruedita de carga si está conectándose
                        child: _estaCargando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 2),
                              )
                            : const Text('Iniciar Sesión', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// MENÚ PRINCIPAL (El Dashboard con las pestañas)
// ==========================================================
class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({super.key});

  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  int _pestanaActual = 0;

  final List<Widget> _pantallas = [
    const PantallaInicio(),
    const PantallaInformacion(),
    const PantallaSeguimiento(),
    const PantallaDesempeno(), 
    const PantallaBecas(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Sistema Integral de Información', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text('Comunidad Estudiantil', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PantallaConfiguracion()),
              );
            },
          ),
        ],
      ),
      body: _pantallas[_pestanaActual],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pestanaActual,
        onDestinationSelected: (int index) {
          setState(() {
            _pestanaActual = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Info'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: 'Seguimiento'),
          NavigationDestination(icon: Icon(Icons.edit_note_outlined), selectedIcon: Icon(Icons.edit_note), label: 'Desempeño'),
          NavigationDestination(icon: Icon(Icons.more_vert), selectedIcon: Icon(Icons.more_vert), label: 'Becas'),
        ],
      ),
    );
  }
}

// ==========================================================
// CONFIGURACIÓN (Con engranaje)
// ==========================================================
class PantallaConfiguracion extends StatefulWidget {
  const PantallaConfiguracion({super.key});

  @override
  State<PantallaConfiguracion> createState() => _PantallaConfiguracionState();
}

class _PantallaConfiguracionState extends State<PantallaConfiguracion> {
  bool _notificacionesActivas = true;
  String _idiomaSeleccionado = 'Español';

  @override
  Widget build(BuildContext context) {
    const Color naranjaUP = Color(0xFFFF8200);
    bool esModoOscuro = modoTemaNotificador.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración del Sistema', style: TextStyle(fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Apariencia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: naranjaUP)),
          const SizedBox(height: 10),
          Card(
            elevation: 1,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Modo Nocturno', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Cambiar tema de la aplicación'),
                  secondary: Icon(esModoOscuro ? Icons.dark_mode : Icons.light_mode, color: naranjaUP),
                  value: esModoOscuro,
                  activeTrackColor: naranjaUP.withOpacity(0.5), 
                  activeColor: naranjaUP, 
                  onChanged: (bool valor) {
                    setState(() {
                      modoTemaNotificador.value = valor ? ThemeMode.dark : ThemeMode.light;
                    });
                  },
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.text_fields, color: naranjaUP),
                          SizedBox(width: 15),
                          Text('Tamaño de Texto', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        ],
                      ),
                      Slider(
                        value: escalaTextoNotificador.value,
                        min: 0.8,
                        max: 1.4,
                        divisions: 3,
                        activeColor: naranjaUP,
                        label: '${(escalaTextoNotificador.value * 100).toInt()}%',
                        onChanged: (valor) {
                          setState(() {
                            escalaTextoNotificador.value = valor;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 25),
          const Text('Preferencias Generales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: naranjaUP)),
          const SizedBox(height: 10),
          Card(
            elevation: 1,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language, color: naranjaUP),
                  title: const Text('Idioma de la interfaz', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: DropdownButton<String>(
                    value: _idiomaSeleccionado,
                    underline: const SizedBox(),
                    items: <String>['Español', 'English'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (String? nuevoValor) {
                      if (nuevoValor != null) {
                        setState(() { _idiomaSeleccionado = nuevoValor; });
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Notificaciones Push', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Avisos y mensajes del SII'),
                  secondary: const Icon(Icons.notifications_active, color: naranjaUP),
                  value: _notificacionesActivas,
                  activeColor: naranjaUP,
                  onChanged: (bool valor) {
                    setState(() { _notificacionesActivas = valor; });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),
          const Text('Seguridad e Información', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: naranjaUP)),
          const SizedBox(height: 10),
          Card(
            elevation: 1,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip, color: naranjaUP),
                  title: const Text('Privacidad de Datos', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: naranjaUP),
                  title: const Text('Acerca de UP-APP', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Versión 1.0.0 (Desarrollo)'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          Center(
            child: TextButton.icon(
              // ¡Este botón ahora te regresa a la pantalla de Login y borra el historial!
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const PantallaLogin()),
                  (Route<dynamic> route) => false,
                );
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Cerrar Sesión Local', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================================
// 1. PANTALLA DE INICIO
// ==========================================================
class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

Future<void> _abrirCalendario() async {
    final Uri url = Uri.parse('https://www.upapnl.edu.mx/calendario-academico');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir $url');
    }
  }
Future<void> _abrirSII() async {
    final Uri url = Uri.parse('http://sip.upnl.edu.mx/alumnos.php/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color naranjaUP = Color(0xFFFF8200);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: naranjaUP, width: 1)),
          elevation: 1,
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.campaign, color: naranjaUP, size: 28),
                    SizedBox(width: 10),
                    Text('AVISOS UPAP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: naranjaUP)),
                  ],
                ),
                SizedBox(height: 10),
                Text('Bienvenido al ciclo escolar 2026. Los avisos importantes aparecerán aquí.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ALEJANDRO GARCÍA LÓPEZ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Matrícula: 20260088', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30),
                _datoRow('Carrera:', 'Ing. en Tecnologías de la Información e Innovación Digital', context),
                _datoRow('Estatus:', 'REGULAR', context, col: Colors.green),
                _datoRow('Generación:', '2023 - 2026', context),
                _datoRow('Promedio Gral:', '9.5', context),
                _datoRow('Mat. Aprobadas:', '32', context),
                _datoRow('Créd. Aprobados:', '210', context),
                _datoRow('Grupo:', 'TI-07-B', context),
              ],
            ),
          ),
        ),
        const SizedBox(height: 25),
        const Text('Panel Principal', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        GridView.count(
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.2,
          children: [
            _btnPanel(Icons.calendar_month, 'Calendario\nEscolar', naranjaUP, onTap: _abrirCalendario, isExternal: true),
            _btnPanel(Icons.payments, 'Catálogo\nde Cuotas', naranjaUP),
            _btnPanel(Icons.menu_book, 'Manual\nde Usuario', naranjaUP),
            _btnPanel(Icons.business_center, 'Estadías y Estadías', naranjaUP, onTap: _abrirSII, isExternal: true),
          ],
        ),
      ],
    );
  }

  Widget _datoRow(String t, String v, BuildContext ctx, {Color? col}) {
    bool isDark = Theme.of(ctx).brightness == Brightness.dark;
    Color valorColor = col ?? (isDark ? Colors.white70 : Colors.black87);
    if (col == Colors.green && isDark) valorColor = Colors.lightGreenAccent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(children: [
        Expanded(flex: 2, child: Text(t, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: isDark ? Colors.grey[400] : Colors.black54))),
        Expanded(flex: 3, child: Text(v, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: valorColor))),
      ]),
    );
  }

Widget _btnPanel(IconData i, String t, Color c, {VoidCallback? onTap, bool isExternal = false}) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap, // Ahora ejecuta la acción que le mandemos
        child: Padding(
          padding: const EdgeInsets.all(8), 
          child: Row(
            children: [
              Icon(i, color: c), 
              const SizedBox(width: 8), 
              Expanded(child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
              
              // Si le decimos que es externo, dibuja este pequeño ícono
              if (isExternal)
                const Icon(Icons.open_in_new, size: 14, color: Colors.grey),
            ]
          )
        ),
      ),
    );
  }
}

// ==========================================
// 2. PANTALLA DE INFORMACIÓN PERSONAL
// ==========================================
class PantallaInformacion extends StatelessWidget {
  const PantallaInformacion({super.key});

  @override
  Widget build(BuildContext context) {
    const Color naranjaUP = Color(0xFFFF8200);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Center(child: CircleAvatar(radius: 50, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 60, color: Colors.white))),
        const SizedBox(height: 20),
        
        _tarjetaInfo('Datos Personales', naranjaUP, [
          _campo('Apellido Paterno', 'García'), _campo('Apellido Materno', 'López'), _campo('Nombre(s)', 'Alejandro'),
          _campo('Fecha Nacimiento', '15 / Ago / 2004'), _campo('Nacionalidad', 'Mexicana'),
          _campo('Estado Nac.', 'Nuevo León'), _campo('Municipio Nac.', 'Monterrey'),
          _campo('Estado Civil', 'Soltero'), _campo('Sexo', 'Masculino'),
          _campo('CURP', 'GALA040815HNLRR01'), _campo('RFC', 'GALA040815XYZ'), _campo('Tipo Sangre', 'A+'),
        ]),

        _tarjetaInfo('Familia y Contacto', naranjaUP, [
          _campo('Nombre Padre', 'Roberto García'), _campo('Nombre Madre', 'Laura López'),
          _campo('Tel. Local', '81 1122 3344'), _campo('Tel. Celular', '81 5566 7788'),
          _campo('Correo Personal', 'alex.garcia@gmail.com'),
        ]),

        _tarjetaInfo('Domicilio', naranjaUP, [
          _campo('Dirección', 'Calle Las Arboledas #123'), _campo('Colonia', 'Centro'),
          _campo('Del. Municipal', 'Apodaca'), _campo('Código Postal', '66600'),
          _campo('Municipio', 'Apodaca'),
        ]),
      ],
    );
  }

  Widget _tarjetaInfo(String tit, Color col, List<Widget> campos) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tit, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: col)),
          const Divider(),
          ...campos,
        ]),
      ),
    );
  }

  Widget _campo(String e, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(e, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
        Text(v, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ==========================================================
// 3. PANTALLA DE SEGUIMIENTO
// ==========================================================
class PantallaSeguimiento extends StatelessWidget {
  const PantallaSeguimiento({super.key});

  @override
  Widget build(BuildContext context) {
    const Color naranjaUP = Color(0xFFFF8200);

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const Material(
            elevation: 1,
            child: TabBar(
              labelColor: naranjaUP, unselectedLabelColor: Colors.grey, indicatorColor: naranjaUP,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                Tab(text: 'Horario', icon: Icon(Icons.calendar_view_week)),
                Tab(text: 'Carga Acad.', icon: Icon(Icons.assignment)),
                Tab(text: 'Historial', icon: Icon(Icons.history)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _tabHorario(),
                _tabCargaAcad(),
                _tabHistorialCuatrimestral(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabHorario() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Hora')),
          DataColumn(label: Text('Lun')), DataColumn(label: Text('Mar')), DataColumn(label: Text('Mié')),
          DataColumn(label: Text('Jue')), DataColumn(label: Text('Vie')), DataColumn(label: Text('Sáb')), DataColumn(label: Text('Dom')),
        ],
        rows: List.generate(8, (i) => DataRow(cells: [
          DataCell(Text('${7+i}:00')), 
          ...List.generate(7, (_) => const DataCell(Text('')))
        ])),
      ),
    );
  }

  Widget _tabCargaAcad() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Materia')),
              DataColumn(label: Text('P1')), DataColumn(label: Text('P2')), DataColumn(label: Text('P3')),
            ],
            rows: const [
              DataRow(cells: [DataCell(Text('Base de Datos')), DataCell(Text('9')), DataCell(Text('10')), DataCell(Text('9'))]),
              DataRow(cells: [DataCell(Text('Redes de Comp.')), DataCell(Text('8')), DataCell(Text('9')), DataCell(Text('10'))]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabHistorialCuatrimestral() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Periodo')), DataColumn(label: Text('Matrícula')), DataColumn(label: Text('Inscripción')),
          DataColumn(label: Text('Programa')), DataColumn(label: Text('Cuatri.')), DataColumn(label: Text('Promedio')), DataColumn(label: Text('Estatus')),
        ],
        rows: const [
          DataRow(cells: [
            DataCell(Text('Sep-Dic 2024')), DataCell(Text('20260088')), DataCell(Text('Nuevo Ingreso')),
            DataCell(Text('Ing. TIID')), DataCell(Text('1')), DataCell(Text('9.5')), DataCell(Text('REGULAR', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
          ]),
        ],
      ),
    );
  }
}

// ==========================================================
// 4. PANTALLA DE DESEMPEÑO
// ==========================================================
class PantallaDesempeno extends StatelessWidget {
  const PantallaDesempeno({super.key}); 

  @override
  Widget build(BuildContext context) {
    const Color naranjaUP = Color(0xFFFF8200);

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const Material(
            elevation: 1,
            child: TabBar(
              labelColor: naranjaUP, unselectedLabelColor: Colors.grey, indicatorColor: naranjaUP,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                Tab(text: 'Historial', icon: Icon(Icons.class_outlined)),
                Tab(text: 'No Acredit.', icon: Icon(Icons.close_rounded)),
                Tab(text: 'Boleta', icon: Icon(Icons.assignment_turned_in_outlined)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _tabHistorialAcademico(context),
                _tabMateriasNoAcreditadas(),
                _tabBoletaCalificaciones(naranjaUP, context), 
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabHistorialAcademico(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color headerColor = isDark ? const Color(0xFF424242) : const Color(0xFFF5F5F5);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Card(
            elevation: 1,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(headerColor), 
              columns: const [
                DataColumn(label: Text('ID')), DataColumn(label: Text('Fecha')), DataColumn(label: Text('Ciclo')),
                DataColumn(label: Text('Clave')), DataColumn(label: Text('Materia')), DataColumn(label: Text('Créd.')),
                DataColumn(label: Text('Cal. Red.')), DataColumn(label: Text('Tipo Eval.')), DataColumn(label: Text('Estado')),
              ],
              rows: [
                _datoKardex('1', '15/Dic/24', '1', 'IS101', 'Intro. a Sistemas', '5', '10', 'ORDINARIO', 'APROBADA'),
                _datoKardex('2', '15/Dic/24', '1', 'MA102', 'Cálculo Diferencial', '6', '9', 'ORDINARIO', 'APROBADA'),
                _datoKardex('3', '15/Dic/24', '1', 'IN103', 'Inglés I', '4', '10', 'ORDINARIO', 'APROBADA'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DataRow _datoKardex(String id, String fecha, String ciclo, String clave, String materia, String cred, String cal, String tipo, String estado) {
    return DataRow(cells: [
      DataCell(Text(id)), DataCell(Text(fecha)), DataCell(Text(ciclo)), DataCell(Text(clave)), DataCell(Text(materia)), DataCell(Text(cred)),
      DataCell(Text(cal, style: const TextStyle(fontWeight: FontWeight.bold))), DataCell(Text(tipo)), 
      DataCell(Text(estado, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
    ]);
  }

  Widget _tabMateriasNoAcreditadas() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 60),
          SizedBox(height: 20),
          Text('No se registran materias', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('sin acreditar.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _tabBoletaCalificaciones(Color colorNaranja, BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color headerColor = isDark ? const Color(0xFF424242) : const Color(0xFFEEEEEE);
    Color finalRowColor = isDark ? const Color(0xFF4E2A00) : const Color(0xFFFFF2E5);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(headerColor), 
              columnSpacing: 25,
              columns: const [
                DataColumn(label: Text('PERIODO CURSADO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                DataColumn(label: Text('CUATRIMESTRE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                DataColumn(label: Text('PROMEDIO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              ],
              rows: [ 
                const DataRow(cells: [DataCell(Text('SEPTIEMBRE - DICIEMBRE 2024')), DataCell(Center(child: Text('1'))), DataCell(Text('9.29'))]),
                const DataRow(cells: [DataCell(Text('ENERO - ABRIL 2025')), DataCell(Center(child: Text('2'))), DataCell(Text('9.14'))]),
                const DataRow(cells: [DataCell(Text('MAYO - AGOSTO 2025')), DataCell(Center(child: Text('3'))), DataCell(Text('9.00'))]),
                
                DataRow(
                  color: WidgetStatePropertyAll(finalRowColor), 
                  cells: [
                    DataCell(Text('PROMEDIO GENERAL', style: TextStyle(fontWeight: FontWeight.bold, color: colorNaranja, fontSize: 14))),
                    const DataCell(Text('')),
                    DataCell(Text('9.25', style: TextStyle(fontWeight: FontWeight.bold, color: colorNaranja, fontSize: 14))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// 5. PANTALLA DE BECAS
// ==========================================================
class PantallaBecas extends StatelessWidget {
  const PantallaBecas({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color headerColor = isDark ? const Color(0xFF424242) : const Color(0xFFF5F5F5);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text('Consulta de Becas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStatePropertyAll(headerColor),
                columnSpacing: 25,
                columns: const [
                  DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Estatus', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Folio Beca', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Cuatrimestre', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Tipo Beca', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Porcentaje Aprobado', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Monto', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Renovación', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Observaciones', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: const [
                  DataRow(cells: [
                    DataCell(Text('1')),
                    DataCell(Text('ACTIVA', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                    DataCell(Text('BEC-2026-0491')),
                    DataCell(Text('7')),
                    DataCell(Text('Excelencia Académica')),
                    DataCell(Text('100%')),
                    DataCell(Text('\$2,500.00')),
                    DataCell(Text('Automática')),
                    DataCell(Text('Ninguna')),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}