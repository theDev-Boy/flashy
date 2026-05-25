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
subprojects {
    project.evaluationDependsOn(":app")
}

// Fix: Set namespace on library plugins that don't specify one (e.g. old file_picker 3.0.4)
// Uses withPlugin instead of afterEvaluate to avoid 'already evaluated' error
subprojects {
    pluginManager.withPlugin("com.android.library") {
        val libExt = project.extensions.findByType(com.android.build.api.dsl.LibraryExtension::class.java)
        if (libExt != null && libExt.namespace == null) {
            libExt.namespace = (project.group as? String) ?: "com.${project.name}"
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
