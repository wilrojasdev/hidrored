allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// Algunos plugins (p. ej. `printing` y otros que dependen de androidx.core
// reciente) usan atributos como `android:attr/lStar` introducidos en API 31,
// pero declaran compileSdk antiguo en su propio build.gradle. Forzamos
// compileSdk 34 a TODOS los módulos library para evitar el error
// "resource android:attr/lStar not found" durante la compilación release.
//
// IMPORTANTE: este bloque debe ir ANTES de `evaluationDependsOn(":app")`,
// porque ese trigger evalúa los subproyectos y rompe registros tardíos
// con "Cannot run Project.afterEvaluate when project is already evaluated".
subprojects {
    afterEvaluate {
        plugins.withId("com.android.library") {
            extensions.configure<com.android.build.gradle.LibraryExtension> {
                if (compileSdk == null || (compileSdk ?: 0) < 34) {
                    compileSdk = 34
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
