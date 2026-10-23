# Sistema web con machine learning para el control del transporte escolar

Proyecto Integrador II – Ingeniería de Sistemas, Universidad Privada Franz Tamayo.
Caso: U.E. Marcelo Quiroga Santa Cruz (El Alto, Bolivia).

El sistema permite ver en tiempo real la ubicación del bus escolar (GPS del celular del conductor), registrar la subida y bajada de los estudiantes con huella dactilar, avisar a los padres y anticipar bloqueos viales con un modelo Random Forest y la API de Google Maps.

## Tecnologías

- HTML5, CSS3, JavaScript, Leaflet + OpenStreetMap
- PHP 8.2 (patrón MVC) y MySQL con PDO
- Python, scikit-learn, pandas, numpy y Flask/FastAPI para el modelo predictivo

## Estructura del repositorio

```
database/   Scripts SQL (esquema, datos de prueba y consultas)
docs/       Modelo relacional y diagramas de clases
```

## Flujo de ramas

| Rama | Uso |
|---|---|
| `main` | Versiones estables que se entregan |
| `develop` | Integración del trabajo en curso |
| `feature/*` | Una rama por funcionalidad, creada desde `develop` y unida de vuelta a `develop` |

Cuando `develop` está estable, se une a `main` con una versión etiquetada.
