package edu.algo2.eventos.controller

import edu.algo2.eventos.Evento
import edu.algo2.eventos.Usuario
import edu.algo2.eventos.config.ServiceLocator
import edu.algo2.eventos.excepciones.RepositorioException
import java.util.ArrayList
import java.util.Collection
import org.uqbar.commons.model.exceptions.UserException
import org.uqbar.xtrest.api.Result
import org.uqbar.xtrest.api.annotation.Body
import org.uqbar.xtrest.api.annotation.Controller
import org.uqbar.xtrest.api.annotation.Delete
import org.uqbar.xtrest.api.annotation.Get
import org.uqbar.xtrest.api.annotation.Put
import org.uqbar.xtrest.json.JSONUtils
import edu.algo2.eventos.EventoAbierto

@Controller
class EventosController {
	extension JSONUtils = new JSONUtils
	
	@Get("/locaciones")
	def Result locaciones() {
		try {
			val locaciones = ServiceLocator.instance.repoLocaciones.elementos
			ok(locaciones.toJson)
		} catch (Exception e) {
			internalServerError(e.message)
		}
	}
	
	@Get("/agenda/:idUsuario")
	def Result agendaDeUsuario() {
		try {
			val usuarioId = Integer.valueOf(idUsuario)
			ok(getUsuarioById(usuarioId).obtenerAgenda.toJacksonList.toJson)
		} catch (NumberFormatException e) {
			badRequest("El id no es valido " + idUsuario)
		} catch (RepositorioException e) {
			notFound(e.message)
		} catch (Exception e) {
			internalServerError(e.message)
		}
	}
	
	@Get("/eventosDeInteres/:idUsuario")
	def Result eventosDeInteresDelUsuario() {
		try {
			val usuarioId = Integer.valueOf(idUsuario)
			ok(getUsuarioById(usuarioId).obtenerEventosDeInteres.toJacksonList.toJson)
		} catch (NumberFormatException e) {
			badRequest("El id no es valido " + idUsuario)
		} catch (RepositorioException e) {
			notFound(e.message)
		} catch (Exception e) {
			internalServerError(e.message)
		}
	}
	
	@Get("/entradas/:idUsuario")
	def Result entradasDelUsuario() {
		try {
			val usuarioId = Integer.valueOf(idUsuario)
			ok(getUsuarioById(usuarioId).getEntradas.toJson)
		} catch (NumberFormatException e) {
			badRequest("El id no es valido " + idUsuario)
		} catch (RepositorioException e) {
			notFound(e.message)
		} catch (Exception e) {
			internalServerError(e.message)
		}
	}
	
	protected def Usuario getUsuarioById(Integer usuarioId) {
		ServiceLocator.instance.repoUsuarios.searchById(usuarioId)
	}
	
	@Get("/organizados/:idUsuario")
	def Result organizadosDeUsuario() {
		try {
			val usuarioId = Integer.valueOf(idUsuario)
			ok(getUsuarioById(usuarioId).eventos.toJacksonList.toJson)
		} catch (NumberFormatException e) {
			badRequest("El id no es valido " + idUsuario)
		} catch (RepositorioException e) {
			notFound(e.message)
		} catch (Exception e) {
			internalServerError(e.message)
		}
	}
	
	@Get("/invitaciones/:idUsuario")
	def Result invitacionesDeUsuario() {
		try {
			val usuarioId = Integer.valueOf(idUsuario)
			ok(getUsuarioById(usuarioId).invitaciones.toJson)
		} catch (NumberFormatException e) {
			badRequest("El id no es valido " + idUsuario)
		} catch (RepositorioException e) {
			notFound(e.message)
		} catch (Exception e) {
			internalServerError(e.message)
		}
	}
	
	@Get("/perfil/:idUsuario")
	def Result perfilDeUsuario() {
		try {
			val usuarioId = Integer.valueOf(idUsuario)
			ok(getUsuarioById(usuarioId).toJson)
		} catch (NumberFormatException e) {
			badRequest("El id no es valido " + idUsuario)
		} catch (RepositorioException e) {
			notFound(e.message)
		} catch (Exception e) {
			internalServerError(e.message)
		}
	}
	
	@Get("/amigos/:idUsuario")
	def Result amigosDeUsuario() {
		try {
			val usuarioId = Integer.valueOf(idUsuario)
			ok(getUsuarioById(usuarioId).amigos.toJson)
		} catch (NumberFormatException e) {
			badRequest("El id no es valido " + idUsuario)
		} catch (RepositorioException e) {
			notFound(e.message)
		} catch (Exception e) {
			internalServerError(e.message)
		}
	}
	
	@Put("/eliminarAmigo/:idUsuario")
	def Result eliminarAmigoDeUsuario(@Body String body) {
		try {
			val usuarioId = Integer.valueOf(idUsuario)
			val amigoId = body.fromJson(Integer)
			val usuario = getUsuarioById(usuarioId)
			val amigo = getUsuarioById(amigoId)
			usuario.eliminarAmigo(amigo)
			ok('{ "status" : "OK" }')
		} catch (NumberFormatException e) {
			badRequest("El id no es valido " + e.message)
		} catch (RepositorioException e) {
			notFound(e.message)
		} catch (Exception e) {
			internalServerError(e.message)
		}
	}
	
	@Put("/aceptarInvitacion/:idUsuario")
	def Result aceptarInvitacionDeUsuario(@Body String body) {
		try {
			val usuarioId = Integer.valueOf(idUsuario)
			val eventoId = body.getPropertyAsInteger("eventoId")
			val acompaniantes = body.getPropertyAsInteger("acompaniantes")
			val usuario = getUsuarioById(usuarioId)
			val evento = ServiceLocator.instance.repoEventos.searchById(eventoId)
			usuario.aceptarInvitacion(evento, acompaniantes)
			ok('{ "status" : "OK" }')
		} catch (NumberFormatException e) {
			badRequest("El id no es valido " + e.message)
		} catch (RepositorioException e) {
			notFound(e.message)
		} catch (Exception e) {
			internalServerError(e.message)
		}
	}
	
	@Put("/rechazarInvitacion/:idUsuario")
	def Result rechazarInvitacionDeUsuario(@Body String body) {
		try {
			val usuarioId = Integer.valueOf(idUsuario)
			val eventoId = body.fromJson(Integer)
			val usuario = getUsuarioById(usuarioId)
			val evento = ServiceLocator.instance.repoEventos.searchById(eventoId)
			usuario.rechazarInvitacion(evento)
			ok('{ "status" : "OK" }')
		} catch (NumberFormatException e) {
			badRequest("El id no es valido " + e.message)
		} catch (RepositorioException e) {
			notFound(e.message)
		} catch (Exception e) {
			internalServerError(e.message)
		}
	}
	
	@Put("/nuevoEvento/:idUsuario")
	def Result nuevoEventoDeUsuario(@Body String body) {
		try {
			val usuarioId = Integer.valueOf(idUsuario)
			val usuario = getUsuarioById(usuarioId)
			val evento = body.fromJson(Evento)
			if (evento.locacion === null) {
				return badRequest("La locacion no es valida")
			}
			evento.locacion = ServiceLocator.instance.repoLocaciones.searchById(evento.locacion.id)
			usuario.organizarUnEvento(evento)
			ok('{ "status" : "OK" }')
		} catch (NumberFormatException e) {
			badRequest("El id no es valido " + e.message)
		} catch (RepositorioException e) {
			notFound(e.message)
		} catch (Exception e) {
			internalServerError(e.message)
		}
	}
	
	@Delete("/devolverEntrada")
	def Result devolverEntrada(@Body String body) {
		try {
			val usuarioId = body.getPropertyAsInteger("usuarioId")
			val eventoId = body.getPropertyAsInteger("eventoId")
			val usuario = getUsuarioById(usuarioId)
			val evento = ServiceLocator.instance.repoEventos.searchById(eventoId)
			val entrada = usuario.entradaDeEvento(evento)
			entrada.devolver
			ok('{ "status" : "OK" }')
		} catch (NumberFormatException e) {
			badRequest("El id no es valido " + e.message)
		} catch (RepositorioException e) {
			notFound(e.message)
		} catch (UserException e) {
			notFound(e.message)
		} catch (Exception e) {
			internalServerError(e.message)
		}
	}
	
	@Put("/comprarEntrada")
	def Result comprarEntrada(@Body String body) {
		try {
			val usuarioId = body.getPropertyAsInteger("usuarioId")
			val eventoId = body.getPropertyAsInteger("eventoId")
			val cantidad = body.getPropertyAsInteger("cantidad")
			val usuario = getUsuarioById(usuarioId)
			val evento = ServiceLocator.instance.repoEventos.searchById(eventoId) as EventoAbierto
			usuario.comprarEntrada(evento,cantidad)
			ok('{ "status" : "OK" }')
		} catch (NumberFormatException e) {
			badRequest("El id no es valido " + e.message)
		} catch (RepositorioException e) {
			notFound(e.message)
		} catch (UserException e) {
			notFound(e.message)
		} catch (Exception e) {
			internalServerError(e.message)
		}
	}
	
	def toJacksonList(Collection<Evento> eventos) {
		new EventoList => [addAll(eventos)]
	}
	
	//Workaround: "No muestra el tipo de evento al hacer toJson"
	static private class EventoList extends ArrayList<Evento> { }
}


