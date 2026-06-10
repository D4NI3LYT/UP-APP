import 'package:flutter/material.dart';

void main() {
  runApp(const MiAppEstudiante());
}

class MiAppEstudiante extends StatelessWidget {
  const MiAppEstudiante({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UP-APP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF8200), // Color de su paleta elegida
          primary: const Color(0xFFFF8200),
        ),
        useMaterial3: true,
      ),
      home: const MenuPrincipal(),
    );
  }
}

class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({super.key});

  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  int _pestanaActual = 0;

  // PASO 1: Vinculamos cada pestaña a su propio Widget especializado
  final List<Widget> _pantallas = [
    const PantallaInicio(),       // Componente para la pestaña de Inicio
    const PantallaInformacion(), // Componente para Información Personal
    const Center(child: Text('Seguimiento cuatrimestral', style: TextStyle(fontSize: 20))),
    const Center(child: Text('Desempeño académico', style: TextStyle(fontSize: 20))),
    const Center(child: Text('Lista de opciones restantes de la APP', style: TextStyle(fontSize: 20))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'UP-APP', 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Sistema Integral de Información', 
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configuración',
            onPressed: () {
              print('Abrir ajustes de la aplicación');
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
        // SUGERENCIA UI: Cambiamos los iconos genéricos por unos acordes a cada sección
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Información',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Seguimiento',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Desempeño',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz_rounded),
            label: 'Ver más',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// PESTAÑA 1: DISEÑO DE LA PANTALLA DE INICIO
// ==========================================
class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos ListView para que si agregamos muchas tarjetas, el alumno pueda hacer scroll
    return ListView(
      padding: const EdgeInsets.all(16.0), // Margen alrededor de toda la pantalla
      children: [
        const Text(
          '¡Hola de nuevo!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5), // Espacio en blanco de separación
        const Text(
          'Revisa las novedades de la Universidad Politécnica.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),

        // Tarjeta de Aviso 1 (Estilo Canvas)
        Card(
          elevation: 2, // Qué tanta sombra proyecta la tarjeta
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Margen interno de la tarjeta
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.campaign, color: Color(0xFFFF8200)),
                    SizedBox(width: 10),
                    Text('Aviso Importante', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('Recuerda que la evaluación docente del cuatrimestre ya está disponible en el SII. Es obligatorio responderla.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// PESTAÑA 2: INFORMACIÓN PERSONAL DEL ALUMNO
// ==========================================
class PantallaInformacion extends StatelessWidget {
  const PantallaInformacion({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Perfil del Estudiante',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // Tarjeta con los datos del alumno (Estilo credencial digital)
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFFFF8200),
                  child: Icon(Icons.school, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Santiago Arroyo Garza', // Dato de ejemplo basado en su plantilla
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text('Matrícula: 20260001', style: TextStyle(color: Colors.grey)),
                const Divider(height: 30), // Línea divisora fina
                
                // Filas de información técnica
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Carrera:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Ing. en Tecnologías de la Información'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Estatus:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('REGULAR', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}