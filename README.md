<div align="center">
  <img src="assets/icons/el_papeleo_ico.png" alt="El Papeleo Logo" width="120" height="120"/>
  <br/>
  <img src="assets/images/el_papeleo.png" alt="El Papeleo" height="60"/>
</div>

<br/>

<div align="center">
  
  **Tu guía offline de trámites cubanos**

  ![Version](https://img.shields.io/badge/version-1.0.3-brightgreen)
  ![Flutter](https://img.shields.io/badge/Flutter-3.44-blue)
  ![License](https://img.shields.io/badge/license-MIT-orange)

</div>

---

## 📱 Sobre la App

**El Papeleo** es una aplicación móvil Android diseñada para ser una guía completa y siempre disponible de los trámites y gestiones oficiales en Cuba. Construida con Flutter y con una arquitectura **offline-first**, te permite consultar información detallada de trámites incluso sin conexión a internet.

> 🇨🇺 *Hecha por cubanos, para cubanos.*

---

## ✨ Características

| Funcionalidad | Descripción |
|--------------|-------------|
| 🏠 **Explorar Trámites** | Navega por más de 80 trámites organizados en 26 categorías |
| 🔍 **Búsqueda** | Encuentra cualquier trámite al instante con búsqueda en tiempo real |
| ⭐ **Favoritos** | Guarda tus trámites más usados para acceso rápido |
| 📋 **Detalle Completo** | Cada trámite incluye: requisitos, costos, horarios, plazos y ubicación |
| 📍 **Mapas** | Abre la ubicación de cada trámite directamente en Google Maps |
| 💡 **Sugerencias** | Envía ideas para mejorar la app o solicitar nuevos trámites |
| 💬 **Foro Público** | Vota y comenta sugerencias de otros usuarios |
| 🔔 **Notificaciones** | Recibe alertas cuando cambie el estado de tus sugerencias |
| 📡 **Tiempo Real** | Las actualizaciones llegan al instante vía Supabase Realtime |
| 📶 **Offline-First** | Consulta toda la información sin conexión a internet |
| 🔄 **Sincronización** | Los datos se actualizan automáticamente al tener conexión |
| 🆕 **Actualizaciones OTA** | Recibe notificaciones de nuevas versiones desde la misma app |

---

## 🎨 Diseño

La interfaz utiliza una paleta de colores inspirada en la bandera cubana:

- **Verde Esperanza** (`#2E8B57`) — Acciones positivas, éxito
- **Azul Confianza** (`#1F618D`) — Información, navegación
- **Amarillo Sol** (`#F4D03F`) — Advertencias, en revisión
- **Rojo Cautela** (`#C0392B`) — Errores, destacar

---

## 🏗️ Stack Tecnológico

| Componente | Tecnología |
|------------|-----------|
| **Framework** | Flutter 3.44 (Dart 3.12) |
| **Estado** | Riverpod + GoRouter |
| **Backend** | Supabase (PostgreSQL + Realtime) |
| **Caché Local** | Hive (almacenamiento NoSQL) |
| **Conectividad** | connectivity_plus |
| **Notificaciones** | MethodChannel + Kotlin nativo |
| **Actualizaciones** | GitHub Releases API |
| **Autenticación** | Device Hash (SHA-256) — sin login |

---

## 📥 Descargar

[<img src="https://img.shields.io/badge/Descargar-APK-v1.0.3-brightgreen?style=for-the-badge&logo=android" alt="Download APK" height="40">](https://github.com/Rexxar0102/El_Papeleo/releases/latest)

> Requiere Android 7.0+ (API 24)

---

## 🧩 Funcionalidades Técnicas

### Offline-First
Los datos se almacenan localmente en Hive al primer acceso. Cuando hay conexión, la app sincroniza en segundo plano con Supabase. Sin conexión, todos los trámites y categorías siguen disponibles.

### Sugerencias en Tiempo Real
Cada sugerencia tiene un ciclo de vida con estados: `pendiente` → `en_revision` → `finalizado`/`rechazado`. Los cambios se reflejan al instante mediante Realtime Subscriptions de Supabase.

### Límite Inteligente
Cada dispositivo puede crear hasta **3 sugerencias activas**, fomentando la calidad sobre la cantidad.

### Notificaciones Nativas
Las notificaciones se manejan desde Kotlin puro (sin Firebase), con un canal dedicado para cambios de estado en sugerencias.

### Actualizaciones Automáticas
La app verifica la disponibilidad de nuevas versiones consultando las releases de GitHub, descarga el APK y abre el instalador automáticamente.

---

## 📸 Capturas de Pantalla

*(Próximamente)*

---

## 📄 Licencia

```
MIT License

Copyright (c) 2025 Qvasoft

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files...
```

---

<div align="center">
  <sub>Hecho con ❤️ por <a href="mailto:qvasoft.cu@gmail.com">Qvasoft</a> — La Habana, Cuba</sub>
  <br/>
  <sub>¿Preguntas o sugerencias? Escríbenos a <b>qvasoft.cu@gmail.com</b></sub>
</div>
