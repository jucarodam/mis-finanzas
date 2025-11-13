# 💰 Mis Finanzas - Aplicación de Gestión Financiera Personal

Una aplicación completa desarrollada en **Flutter Web** para gestionar finanzas personales con una interfaz moderna y Material 3.

## ✨ Características Principales

### 📊 Dashboard Intuitivo
- Resumen visual de ingresos, gastos y balance disponible
- Gráfico de distribución de gastos por categoría (Pie Chart)
- Evolución mensual de ingresos y gastos (Line Chart)
- Alertas cuando los gastos superan el límite configurado

### 💵 Gestión de Ingresos
- Registro de ingresos mensuales (salario, ventas, proyectos, comisiones)
- Categorización personalizada
- Vista de resumen con total del mes
- Edición y eliminación de registros

### 💸 Gestión de Gastos
- Registro de gastos fijos y variables
- Marcado de gastos recurrentes/fijos mensuales
- Categorías predefinidas (Alimentación, Vivienda, Servicios, etc.)
- CRUD completo con edición y eliminación

### 🏷️ Categorías Personalizables
- 15 categorías predefinidas con iconos emoji
- Creación de categorías personalizadas
- Selección de color y emoji para cada categoría
- Separación entre categorías de ingresos y gastos

### 📈 Estadísticas Avanzadas
- Vista mensual con selector de fecha
- Gráfico de barras por categoría
- Top 5 categorías de gastos con porcentajes
- Análisis detallado de distribución

### ⚙️ Configuración
- Modo oscuro/claro
- Configuración de límite mensual de gastos
- Porcentaje de advertencia personalizable
- Información de la aplicación

## 🏗️ Arquitectura

```
lib/
├── database/
│   └── hive_service.dart          # Servicio de base de datos local
├── models/
│   ├── transaction_model.dart     # Modelo de transacciones
│   ├── category_model.dart        # Modelo de categorías
│   └── budget_model.dart          # Modelo de configuración
├── providers/
│   ├── transaction_provider.dart  # Estado de transacciones
│   ├── category_provider.dart     # Estado de categorías
│   ├── settings_provider.dart     # Estado de configuración
│   └── theme_provider.dart        # Estado del tema
├── views/
│   ├── home_screen.dart           # Pantalla principal con navegación
│   ├── dashboard_screen.dart      # Dashboard con gráficos
│   ├── income_screen.dart         # Gestión de ingresos
│   ├── expense_screen.dart        # Gestión de gastos
│   ├── categories_screen.dart     # Gestión de categorías
│   ├── statistics_screen.dart     # Estadísticas avanzadas
│   └── settings_screen.dart       # Configuración
├── widgets/
│   ├── summary_card.dart          # Card de resumen
│   ├── transaction_list_item.dart # Item de lista de transacciones
│   ├── category_chip.dart         # Chip de categoría
│   └── transaction_form.dart      # Formulario de transacciones
├── utils/
│   ├── currency_formatter.dart    # Formateador de moneda COP
│   └── constants.dart             # Constantes de la app
├── theme/
│   └── app_theme.dart             # Temas claro y oscuro
└── main.dart                      # Punto de entrada
```

## 🛠️ Tecnologías

- **Flutter 3.0+** - Framework de desarrollo
- **Provider** - Gestión de estado
- **Hive** - Base de datos local NoSQL
- **fl_chart** - Gráficos interactivos
- **Material 3** - Sistema de diseño
- **intl** - Internacionalización y formato de moneda

## 🎨 Diseño

- **Material 3** con diseño moderno y minimalista
- **Responsive** adaptado para web y móvil
- **Modo oscuro** completo
- **Animaciones** suaves y transiciones
- **Colores** neutros con acentos en verde/azul
- **Tipografía** moderna y legible

## 💾 Persistencia de Datos

Los datos se almacenan localmente usando **Hive**, una base de datos NoSQL rápida y ligera:

- ✅ Funciona offline
- ✅ Datos persistentes en el navegador
- ✅ Acceso rápido sin latencia
- ✅ Preparado para sincronización futura

## 🚀 Instalación y Ejecución

### Prerrequisitos
- Flutter SDK 3.0 o superior
- Un navegador web moderno

### Pasos

1. **Clonar el repositorio**
```bash
git clone <repository-url>
cd mis-finanzas
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Ejecutar en modo web**
```bash
flutter run -d chrome
```

4. **Compilar para producción**
```bash
flutter build web
```

## 📱 Uso de la Aplicación

### Primeros Pasos

1. **Configura tu límite mensual**
   - Ve a Configuración
   - Establece tu límite mensual de gastos
   - Ajusta el porcentaje de advertencia

2. **Registra tu salario**
   - Ve a la sección de Ingresos
   - Toca "Agregar Ingreso"
   - Selecciona la categoría "Salario"
   - Ingresa el monto

3. **Registra tus gastos**
   - Ve a la sección de Gastos
   - Toca "Agregar Gasto"
   - Selecciona una categoría
   - Marca como "Fijo" si es recurrente

4. **Revisa tu Dashboard**
   - Observa el resumen de tus finanzas
   - Analiza los gráficos
   - Monitorea tu balance disponible

### Funcionalidades Destacadas

- **Gastos Fijos**: Marca tus gastos recurrentes mensuales
- **Filtrado por mes**: En Estadísticas, navega entre meses
- **Categorías personalizadas**: Crea las categorías que necesites
- **Modo oscuro**: Cambia el tema en Configuración
- **Alertas de límite**: Recibe advertencias al acercarte a tu límite

## 🎯 Características Futuras (Roadmap)

- [ ] Exportación a CSV/Excel
- [ ] Filtros por categoría y rango de fechas
- [ ] Sincronización en la nube
- [ ] Múltiples cuentas/billeteras
- [ ] Presupuesto por categoría
- [ ] Metas de ahorro
- [ ] Recordatorios de pagos
- [ ] Reportes PDF

## 📄 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

## 👨‍💻 Desarrollado con ❤️

Desarrollado con Flutter y Material 3 para ayudarte a gestionar tus finanzas personales de manera efectiva.

---

**¡Empieza a tomar control de tus finanzas hoy!** 💪💰
