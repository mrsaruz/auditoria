
Para esta prueba técnica, he querido enfocar la herramienta en un caso de uso real, crítico y específico: la prevención de fugas de datos en los flujos de comunicación con equipos externos y talento en una productora audiovisual por varias razones:

- Activos de alto valor (Propiedad intelectual): En una productora se manejan guiones, planes
de rodaje, presupuestos y contratos de exclusividad. Una filtración de estos documentos antes del estreno puede arruinar campañas de marketing enteras o suponer pérdidas millonarias.

- Privacidad y datos densibles: Se gestionan datos personales de actores, extras y equipo técnico (DNI, números de cuenta para pagos, correos personales). Un error operativo expone a la empresa a sanciones graves por incumplimiento de protección de datos.

- Presión y agilidad operativa: El ritmo de una productora es frenético. Los equipos de producción suelen priorizar la rapidez ("enviar el guion urgente a esta agencia externa") frente a los protocolos de seguridad, lo que convierte al correo electrónico en el vector de fuga de datos número uno.

Para diseñar una solución me he basado en:

Primero, fui directa al punto débil: la gente. Con las prisas de los rodajes, es súper normal que alguien mande un guion o un contrato a un Gmail personal o la lie poniendo todos los correos en el "Para" en vez de en copia oculta. Quería una herramienta que cazara esos despistes del día a día.

Luego, tenía claro que la herramienta no podía convertirse en un problema de privacidad. Por eso la diseñé al mínimo: lee los correos y los adjuntos, pero jamás guarda el contenido sensible. Solo rescata metadatos, fechas y el nivel de riesgo para cumplir con el RGPD y sin meternos en líos de cotillear.

Y a nivel técnico, usé Microsoft Graph con PowerShell. Con eso creé un script que puedes correr en un momento y que, en vez de soltarte una lista infinita de datos, te clasifica todo por niveles de riesgo para que vayas a tiro hecho.

Pude probarlo, pero necesitaba enviar varios emaiils con las palabras clave, pero no me llegó a dar
tiempo. 
