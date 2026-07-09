import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'datos_simulados.dart';

final ValueNotifier<ThemeMode> modoTemaNotificador = ValueNotifier(ThemeMode.light);
final ValueNotifier<double> escalaTextoNotificador = ValueNotifier(1.0);
Map<String, dynamic>? usuarioActual;

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
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(seedColor: naranjaUP, primary: naranjaUP, brightness: Brightness.light, surface: const Color(0xFFF5F5F5)),
                appBarTheme: const AppBarTheme(backgroundColor: naranjaUP, foregroundColor: Colors.white, elevation: 2),
                cardColor: Colors.white,
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(seedColor: naranjaUP, primary: naranjaUP, brightness: Brightness.dark, surface: const Color(0xFF121212)),
                appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF212121), foregroundColor: naranjaUP, elevation: 2),
                cardColor: const Color(0xFF303030),
              ),
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
// 0. PANTALLA: LOGIN 
// ==========================================================
class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});
  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _estaCargando = false;

  void _mostrarMensajeError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _iniciarSesion(String matricula, String password) async {
    if (matricula.isEmpty || password.isEmpty) {
      _mostrarMensajeError('Por favor, ingresa tu matrícula y contraseña.');
      return;
    }
    setState(() { _estaCargando = true; });
    await Future.delayed(const Duration(seconds: 1));

    if (DatosSimulados.estudiantes.containsKey(matricula) && password == matricula) {
      usuarioActual = DatosSimulados.estudiantes[matricula];
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MenuPrincipal()));
    } else {
      _mostrarMensajeError('Matrícula o contraseña incorrectos.');
    }
    if (mounted) setState(() { _estaCargando = false; });
  }

  @override
  Widget build(BuildContext context) {
    const Color naranjaUP = Color(0xFFFF8200);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                decoration: BoxDecoration(color: naranjaUP, borderRadius: BorderRadius.circular(15)),
                child: const Center(
                  child: Text('UNIVERSIDAD\nPOLITÉCNICA\nDE APODACA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
                ),
              ),
              const SizedBox(height: 40),
              const Text('Bienvenido a la Comunidad\nEstudiantil', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(25.0),
                decoration: BoxDecoration(color: naranjaUP, borderRadius: BorderRadius.circular(15)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Matrícula', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _matriculaController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(filled: true, fillColor: const Color(0xFFD9D9D9), border: OutlineInputBorder(borderRadius: BorderRadius.circular(0), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
                    ),
                    const SizedBox(height: 20),
                    const Text('Contraseña:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _passwordController, obscureText: true, style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(filled: true, fillColor: const Color(0xFFD9D9D9), border: OutlineInputBorder(borderRadius: BorderRadius.circular(0), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: _estaCargando ? null : () => _iniciarSesion(_matriculaController.text.trim(), _passwordController.text.trim()),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8EAF6), foregroundColor: Colors.black87, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: _estaCargando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 2)) : const Text('Iniciar Sesión', style: TextStyle(fontSize: 16)),
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
// MENÚ PRINCIPAL
// ==========================================================
class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({super.key});
  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  int _pestanaActual = 0;
  final List<Widget> _pantallas = [const PantallaInicio(), const PantallaInformacion(), const PantallaSeguimiento(), const PantallaDesempeno(), const PantallaBecas()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Sistema Integral de Información', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)), Text('Comunidad Estudiantil', style: TextStyle(fontSize: 12, color: Colors.white70))]),
        actions: [IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaConfiguracion())))],
      ),
      body: _pantallas[_pestanaActual],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pestanaActual,
        onDestinationSelected: (int index) => setState(() => _pestanaActual = index),
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
// CONFIGURACIÓN 
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
      appBar: AppBar(title: const Text('Configuración del Sistema', style: TextStyle(fontSize: 16))),
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
                  activeTrackColor: naranjaUP.withOpacity(0.5), activeColor: naranjaUP,
                  onChanged: (bool valor) => setState(() => modoTemaNotificador.value = valor ? ThemeMode.dark : ThemeMode.light),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [Icon(Icons.text_fields, color: naranjaUP), SizedBox(width: 15), Text('Tamaño de Texto', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16))]),
                      Slider(
                        value: escalaTextoNotificador.value, min: 0.8, max: 1.4, divisions: 3, activeColor: naranjaUP,
                        label: '${(escalaTextoNotificador.value * 100).toInt()}%',
                        onChanged: (valor) => setState(() => escalaTextoNotificador.value = valor),
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
                    value: _idiomaSeleccionado, underline: const SizedBox(),
                    items: <String>['Español', 'English'].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                    onChanged: (String? nuevoValor) { if (nuevoValor != null) setState(() => _idiomaSeleccionado = nuevoValor); },
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Notificaciones Push', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Avisos y mensajes del SII'),
                  secondary: const Icon(Icons.notifications_active, color: naranjaUP),
                  value: _notificacionesActivas, activeColor: naranjaUP,
                  onChanged: (bool valor) => setState(() => _notificacionesActivas = valor),
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
              onPressed: () {
                usuarioActual = null;
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const PantallaLogin()), (Route<dynamic> route) => false);
              },
              icon: const Icon(Icons.logout, color: Colors.red), label: const Text('Cerrar Sesión Local', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) throw Exception('No se pudo abrir $url');
  }
  
  Future<void> _abrirSII() async {
    final Uri url = Uri.parse('http://sip.upnl.edu.mx/alumnos.php/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) throw Exception('No se pudo abrir $url');
  }

  @override
  Widget build(BuildContext context) {
    const Color naranjaUP = Color(0xFFFF8200);
    final String nombre = usuarioActual?['nombre'] ?? 'ALUMNO';
    final String matricula = usuarioActual?['matricula'] ?? 'S/N';
    final String carrera = usuarioActual?['carrera'] ?? '';
    final String estatus = usuarioActual?['estatus'] ?? '';

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: naranjaUP, width: 1)),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Icon(Icons.campaign, color: naranjaUP, size: 28), SizedBox(width: 10), Text('AVISOS UPAP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: naranjaUP))]),
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
                Row(children: [Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.person, size: 50, color: Colors.white)), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(nombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), Text('Matrícula: $matricula', style: const TextStyle(color: Colors.grey, fontSize: 14))]))]),
                const Divider(height: 30),
                _datoRow('Carrera:', carrera, context),
                _datoRow('Estatus:', estatus, context, col: Colors.green),
                _datoRow('Promedio Gral:', usuarioActual?['promedio'] ?? '-', context),
                _datoRow('Mat. Aprobadas:', usuarioActual?['materiasAprobadas'] ?? '-', context),
                _datoRow('Créd. Aprobados:', usuarioActual?['creditosAprobados'] ?? '-', context),
              ],
            ),
          ),
        ),
        const SizedBox(height: 25),
        const Text('Panel Principal', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        GridView.count(
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 2.2,
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
    return Padding(padding: const EdgeInsets.only(bottom: 5), child: Row(children: [Expanded(flex: 2, child: Text(t, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: isDark ? Colors.grey[400] : Colors.black54))), Expanded(flex: 3, child: Text(v, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: col ?? (isDark ? Colors.white70 : Colors.black87))))]));
  }
  Widget _btnPanel(IconData i, String t, Color c, {VoidCallback? onTap, bool isExternal = false}) {
    return Card(elevation: 1, child: InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.all(8), child: Row(children: [Icon(i, color: c), const SizedBox(width: 8), Expanded(child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))), if (isExternal) const Icon(Icons.open_in_new, size: 14, color: Colors.grey)]))));
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
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Datos Personales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: naranjaUP)),
                const Divider(),
                _campo('Nombre', usuarioActual?['nombre'] ?? ''),
                _campo('Matrícula', usuarioActual?['matricula'] ?? ''),
                _campo('Carrera', usuarioActual?['carrera'] ?? ''),
                _campo('Estatus Actual', usuarioActual?['estatus'] ?? ''),
                _campo('Generación', usuarioActual?['generacion'] ?? ''),
                _campo('Grupo', usuarioActual?['grupo'] ?? ''),
                _campo('Último Cuatrimestre', usuarioActual?['ultimoCuatri'] ?? ''),
                _campo('Promedio General', usuarioActual?['promedio'] ?? ''),
                _campo('Materias Aprobadas', usuarioActual?['materiasAprobadas'] ?? ''),
                _campo('Créditos Aprobados', usuarioActual?['creditosAprobados'] ?? ''),
                _campo('Materias No Acreditadas', usuarioActual?['materiasNoAcreditadas'] ?? ''),
                _campo('NSS', usuarioActual?['nss'] ?? ''),
              ],
            ),
          ),
        )
      ],
    );
  }
  Widget _campo(String e, String v) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)), Text(v, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))]));
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
          const Material(elevation: 1, child: TabBar(labelColor: naranjaUP, unselectedLabelColor: Colors.grey, indicatorColor: naranjaUP, labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), tabs: [Tab(text: 'Horario', icon: Icon(Icons.calendar_view_week)), Tab(text: 'Carga Acad.', icon: Icon(Icons.assignment)), Tab(text: 'Historial', icon: Icon(Icons.history))])),
          Expanded(
            child: TabBarView(
              children: [
                _crearTablaGenerica(usuarioActual?['horario'], ['Clave', 'Asignatura', 'Aula', 'Grupo', 'Profesor'], ['clave', 'asignatura', 'aula', 'grupo', 'profesor'], context),
                _crearTablaGenerica(usuarioActual?['cargaAcademica'], ['ID', 'Clave', 'Asignatura', 'Tipo Curso', 'Aula', 'Grupo', 'Docente'], ['id', 'clave', 'asignatura', 'tipoCurso', 'aula', 'grupo', 'docente'], context),
                _crearTablaGenerica(usuarioActual?['historialCuatrimestres'], ['Periodo', 'Tipo Inscripción', 'Cuatrimestre', 'Total Materias', 'Promedio', 'Estatus'], ['periodo', 'tipo', 'cuatri', 'materias', 'promedio', 'estatus'], context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _crearTablaGenerica(List<dynamic>? datosRaw, List<String> columnas, List<String> llaves, BuildContext context) {
    if (datosRaw == null || datosRaw.isEmpty) return const Center(child: Text('No se encontraron registros.'));
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color headerColor = isDark ? const Color(0xFF424242) : const Color(0xFFF5F5F5);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Card(
            elevation: 1,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(headerColor),
              columns: columnas.map((e) => DataColumn(label: Text(e, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
              rows: datosRaw.map((filaRaw) {
                final fila = filaRaw as Map<String, dynamic>;
                return DataRow(cells: llaves.map((llave) => DataCell(Text(fila[llave] ?? ''))).toList());
              }).toList(),
            ),
          ),
        ),
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
      // Se redujo a 3 divisiones al eliminar "Historial Académico"
      length: 3,
      child: Column(
        children: [
          const Material(elevation: 1, child: TabBar(isScrollable: true, tabAlignment: TabAlignment.start, labelColor: naranjaUP, unselectedLabelColor: Colors.grey, indicatorColor: naranjaUP, labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), tabs: [Tab(text: 'Boleta de Calificaciones'), Tab(text: 'Materias No Acreditadas'), Tab(text: 'Kardex')])),
          Expanded(
            child: TabBarView(
              children: [
                _tabBoleta(context, naranjaUP),
                const Center(child: Text('NO SE ENCONTRARON REGISTROS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                _crearTablaGenerica(usuarioActual?['kardex'], ['Clave', 'Materia', 'Cuatrimestre', 'Calificación', 'Tipo Evaluación'], ['clave', 'materia', 'cuatri', 'calificacion', 'tipo'], context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBoleta(BuildContext context, Color colorNaranja) {
    final List<dynamic>? promediosRaw = usuarioActual?['promediosBoleta'];
    if (promediosRaw == null || promediosRaw.isEmpty) return const Center(child: Text('Sin registros.'));
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color headerColor = isDark ? const Color(0xFF424242) : const Color(0xFFEEEEEE);
    Color finalRowColor = isDark ? const Color(0xFF4E2A00) : const Color(0xFFFFF2E5);

    List<DataRow> filas = promediosRaw.map((filaRaw) {
      final f = filaRaw as Map<String, dynamic>;
      return DataRow(cells: [DataCell(Text(f['periodo'] ?? '')), DataCell(Center(child: Text(f['cuatri'] ?? ''))), DataCell(Text(f['promedio'] ?? ''))]);
    }).toList();

    filas.add(DataRow(color: WidgetStatePropertyAll(finalRowColor), cells: [DataCell(Text('PROMEDIO GENERAL', style: TextStyle(fontWeight: FontWeight.bold, color: colorNaranja, fontSize: 14))), const DataCell(Text('')), DataCell(Text(usuarioActual?['promedio'] ?? '0.00', style: TextStyle(fontWeight: FontWeight.bold, color: colorNaranja, fontSize: 14)))]));

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Promedios", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(headingRowColor: WidgetStatePropertyAll(headerColor), columnSpacing: 25, columns: const [DataColumn(label: Text('PERIODO CURSADO', style: TextStyle(fontWeight: FontWeight.bold))), DataColumn(label: Text('CUATRIMESTRE', style: TextStyle(fontWeight: FontWeight.bold))), DataColumn(label: Text('PROMEDIO', style: TextStyle(fontWeight: FontWeight.bold)))], rows: filas)),
      ]),
    );
  }

  Widget _crearTablaGenerica(List<dynamic>? datosRaw, List<String> columnas, List<String> llaves, BuildContext context) {
    if (datosRaw == null || datosRaw.isEmpty) return const Center(child: Text('No se encontraron registros.'));
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color headerColor = isDark ? const Color(0xFF424242) : const Color(0xFFF5F5F5);
    return SingleChildScrollView(scrollDirection: Axis.vertical, child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Padding(padding: const EdgeInsets.all(12.0), child: Card(elevation: 1, child: DataTable(headingRowColor: WidgetStatePropertyAll(headerColor), columns: columnas.map((e) => DataColumn(label: Text(e, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(), rows: datosRaw.map((filaRaw) { final fila = filaRaw as Map<String, dynamic>; return DataRow(cells: llaves.map((llave) => DataCell(Text(fila[llave] ?? ''))).toList()); }).toList())))));
  }
}

// ==========================================================
// 5. PANTALLA DE BECAS (Nueva Funcionalidad)
// ==========================================================
class PantallaBecas extends StatelessWidget {
  const PantallaBecas({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color headerColor = isDark ? const Color(0xFF424242) : const Color(0xFFF5F5F5);
    final List<dynamic>? becasRaw = usuarioActual?['becas'];

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text('Consulta de Becas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        if (becasRaw == null || becasRaw.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0), 
              child: Text("NO SE ENCONTRARON BECAS REGISTRADAS.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey))
            )
          )
        else
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStatePropertyAll(headerColor),
                  columns: const [
                    DataColumn(label: Text('Folio', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Estatus', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Tipo Beca', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Porcentaje', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Monto', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Cuatrimestre', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Renovación', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Observaciones', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: becasRaw.map((filaRaw) {
                    final fila = filaRaw as Map<String, dynamic>;
                    return DataRow(cells: [
                      DataCell(Text(fila['folio'] ?? '')),
                      DataCell(Text(fila['estatus'] ?? '', style: TextStyle(color: fila['estatus'] == 'ACTIVA' ? Colors.green : Colors.black, fontWeight: FontWeight.bold))),
                      DataCell(Text(fila['tipo'] ?? '')),
                      DataCell(Text(fila['porcentaje'] ?? '')),
                      DataCell(Text(fila['monto'] ?? '')),
                      DataCell(Text(fila['cuatri'] ?? '')),
                      DataCell(Text(fila['renovacion'] ?? '')),
                      DataCell(Text(fila['obs'] ?? '')),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}