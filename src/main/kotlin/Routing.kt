package dev.rabbithawk256

import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.http.content.*
import io.ktor.server.plugins.cors.routing.*
import io.ktor.server.plugins.origin
import io.ktor.server.response.*
import io.ktor.server.routing.*
import kotlinx.io.files.Path
import kotlinx.io.files.SystemFileSystem
import java.io.File
import kotlin.random.Random

fun Application.configureRouting() {

    install(CORS) {
        anyHost() // @TODO: Don't do this in production if possible. Try to limit it.
    }
    install(IgnoreTrailingSlash)
    routing {
        for (size in SystemFileSystem.list(Path("adPool"))) {
            staticFiles("/${size.name}", File("adPool/${size.name}"))

            get("/${size.name}") {
                val images = SystemFileSystem.list(Path("adPool/${size.name}")).toTypedArray()
                val origin = call.request.origin
                val serverUrl = "${origin.scheme}://${origin.serverHost}:${origin.serverPort}"
                call.respondText("$serverUrl/${size.name}/${images[Random.nextInt(0, images.size)].name}")
            }
        }
    }
}