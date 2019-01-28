package edu.algo2.eventos

import com.fasterxml.jackson.annotation.JsonIgnore
import edu.algo2.eventos.config.ServiceLocator
import edu.algo2.eventos.excepciones.EventoException
import edu.algo2.eventos.excepciones.ServicioTarjetaException
import edu.algo2.eventos.excepciones.ValidacionException
import edu.algo2.repositorio.Entidad
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.temporal.ChronoUnit
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.ccService.CreditCard
import org.uqbar.ccService.CreditCardService
import org.uqbar.commons.model.annotations.TransactionalAndObservable
import org.uqbar.commons.model.exceptions.UserException
import org.uqbar.geodds.Point

@Accessors
@TransactionalAndObservable
class Usuario extends Entidad {
	@JsonIgnore
	val List<String> notificaciones = newArrayList
	@JsonIgnore
	val List<Invitacion> invitaciones = newArrayList
	@JsonIgnore
	val List<Evento> eventos = newArrayList
	@JsonIgnore
	val List<Usuario> amigos = newArrayList
	@JsonIgnore
	val List<Entrada> entradas = newArrayList
	@JsonIgnore
	val List<NotificacionObserver> notificacionObservers = newArrayList
	@JsonIgnore
	val List<Artista> artistasSeguidos = newArrayList
	double saldo = 0d
	String nombreUsuario
	String nombreApellido
	String email
//	@JsonSerialize(using=CustomLocalDateSerializer)
	@JsonIgnore
	LocalDate fechaNacimiento
	@JsonIgnore
	Point direccion
	@JsonIgnore
	Boolean antisocial = false
	@JsonIgnore
	Double radioCercania // en kms
	TipoDeUsuario tipoDeUsuario
	@JsonIgnore
	CreditCardService servicioTarjeta = new CreditCardService

	new() {
	}

	new(String _alias, TipoDeUsuario _tipoDeUsuario) {
		nombreUsuario = _alias
		tipoDeUsuario = _tipoDeUsuario
	}

	def edad() {
		fechaNacimiento.until(LocalDate.now, ChronoUnit.YEARS)
	}

	def aceptacionMasiva() {
		seleccionarInvitacionesAceptables.forEach[aceptarInvitacion(acompaniantes)]
	}

	def seleccionarInvitacionesAceptables() {
		invitaciones.filter [
			amigos.contains(evento.organizador) || evento.cantidadAmigosConcurrentes(this) > 4 || estaCerca(evento)
		]
	}

	def rechazoMasivo() {
		seleccionarInvitacionesRechazables.forEach[rechazarInvitacion]
	}

	def seleccionarInvitacionesRechazables() {
		if (antisocial) {
			invitaciones.filter [
				!estaCerca(evento) || evento.cantidadAmigosConcurrentes(this) < 2
			]
		} else {
			invitaciones.filter [
				!estaCerca(evento) && evento.cantidadAmigosConcurrentes(this) == 0
			]
		}
	}

	def estaCerca(Evento evento) {
		evento.distancia(direccion) <= radioCercania
	}

	def eventosActivos() {
		eventos.filter[estaActivo].size
	}

	def eventosEnMes(Evento evento) {
		eventos.filter[mismoMes(evento)].size
	}

	def puedeOrganizarEvento(Evento evento) {
		tipoDeUsuario.puedeOrganizarEvento(this, evento)
	}

	def puedeModificarEstadoEvento() {
		tipoDeUsuario.puedeModificarEstadoEvento
	}

	def invitacionValida(Invitacion invitacion) {
		tipoDeUsuario.invitacionValida(invitacion)
	}

	def puedeOrganizarEventosAbiertos() {
		tipoDeUsuario.puedeOrganizarEventosAbiertos
	}

	def comprarEntradaConTarjeta(EventoAbierto evento, CreditCard card) {
		val respuesta = servicioTarjeta.pay(card, evento.precio)
		switch (respuesta.statusCode) {
			case 0: {
				comprarEntrada(evento)
			}
			case 1: {
				throw new ServicioTarjetaException(respuesta.statusMessage)
			}
			case 2: {
				throw new ServicioTarjetaException(respuesta.statusMessage)
			}
			default: {
				throw new EventoException("Error del servicio de pagos con tarjeta")
			}
		}
	}

	def comprarEntrada(EventoAbierto evento) {
		comprarEntrada(evento, 1)
	}

	def comprarEntrada(EventoAbierto evento, Integer cantidad) {
		if (tieneSaldoSuficiente(evento, cantidad)) {
			evento.nuevaEntrada(this, cantidad)
		} else {
			throw new EventoException("Saldo insuficiente")
		}
	}

	def tieneSaldoSuficiente(EventoAbierto evento, Integer cantidad) {
		return saldo >= evento.precio * cantidad
	}

	def reducirSaldoPorCompra(Entrada entrada) {
		saldo = saldo - (entrada.evento.precio * entrada.cantidad)
	}

	def agregarEntrada(Entrada entrada) {
		if (tieneEntrada(entrada.evento)) {
			var entradaExistente = entradaDeEvento(entrada.evento)
			entradaExistente.cantidad = entradaExistente.cantidad + entrada.cantidad
		} else {
			entradas.add(entrada)
		}
	}

	def agregarSaldo(double _saldo) {
		saldo += _saldo
	}

	def eliminarEntrada(Entrada entrada) {
		entradas.remove(entrada)
	}

	def enviarInvitacion(EventoCerrado evento, Usuario invitado, int acompaniantes) {
		evento.nuevaInvitacion(invitado, acompaniantes)
	}

	def agregarInvitacion(Invitacion invitacion) {
		invitaciones.add(invitacion)
	}

	def recibirNotificacion(String notificacion) {
		notificaciones.add(notificacion)
	}

	def aceptarInvitacion(Invitacion invitacion, int acompaniantes) {
		invitacion.aceptarInvitacion(acompaniantes)
	}

	def rechazarInvitacion(Invitacion invitacion) {
		invitacion.rechazarInvitacion
	}

	def aceptarInvitacion(Evento evento, int acompaniantes) {
		aceptarInvitacion(buscarInvitacion(evento), acompaniantes)
	}

	def rechazarInvitacion(Evento evento) {
		rechazarInvitacion(buscarInvitacion(evento))
	}

	def buscarInvitacion(Evento evento) {
		val invitacion = invitaciones.findFirst[esDeEvento(evento)]
		if (invitacion === null) {
			throw new UserException("No existe invitacion para el evento " + evento.nombre)
		}
		invitacion
	}

	def cancelarEvento(Evento evento) {
		if (eventos.contains(evento) && puedeModificarEstadoEvento) {
			evento.cancelarEvento
		} else {
			throw new EventoException("No se puede cancelar el evento")
		}
	}

	def postergarEvento(Evento evento, LocalDateTime fecha) {
		if (eventos.contains(evento) && puedeModificarEstadoEvento) {
			evento.postergarEvento(fecha)
		} else {
			throw new EventoException("No se puede posponer el evento")
		}
	}

	def esAmigo(Usuario usuario) {
		amigos.contains(usuario)
	}

	def agregarAmigo(Usuario usuario) {
		amigos.add(usuario)
		usuario.amigos.add(this)
	}

	def eliminarAmigo(Usuario usuario) {
		if (amigos.remove(usuario)) {
			usuario.amigos.remove(this)
		} else {
			throw new UserException("El usuario " + usuario.nombreUsuario + " no es amigo de " + this.nombreUsuario)
		}
	}

	def organizarEventoAbierto(EventoAbierto evento) {
		if (puedeOrganizarEventosAbiertos) {
			organizarEvento(evento)
		} else {
			throw new EventoException("No puede organizar el evento")
		}
	}

	def organizarEventoCerrado(EventoCerrado evento) {
		organizarEvento(evento)
	}

	def private organizarEvento(Evento evento) {
		if (puedeOrganizarEvento(evento)) {
			evento.organizador = this
			ServiceLocator.instance.repoEventos.create(evento)
			eventos.add(evento)
			notificarUsuarios(evento)
		} else {
			throw new EventoException("No puede organizar el evento")
		}
	}

	def notificarUsuarios(Evento evento) {
		notificacionObservers.forEach[enviarNotificacion(evento, this)]
	}

	override tieneNombreIdentificador(String nombreIdentificador) {
		nombreUsuario.equals(nombreIdentificador)
	}

	override validar() {
		if (nombreUsuario === null || nombreUsuario == "") {
			throw new ValidacionException("Error en validacion de nombre de usuario")
		}
		if (nombreApellido === null || nombreApellido == "") {
			throw new ValidacionException("Error en validacion de nombre y apellido")
		}
		if (email === null || email == "") {
			throw new ValidacionException("Error en validacion de email")
		}
		if (fechaNacimiento === null) {
			throw new ValidacionException("Error en validacion de fecha de nacimiento")
		}
		if (direccion === null) {
			throw new ValidacionException("Error en validacion de direccion")
		}
	}

	override actualizar(Entidad elemento) {
		val usuarioActualizado = elemento as Usuario
		nombreUsuario = usuarioActualizado.nombreUsuario
		nombreApellido = usuarioActualizado.nombreApellido
		email = usuarioActualizado.email
		fechaNacimiento = usuarioActualizado.fechaNacimiento
		direccion = usuarioActualizado.direccion
		tipoDeUsuario = usuarioActualizado.tipoDeUsuario ?: tipoDeUsuario
	}

	override tieneValorBusqueda(String valor) {
		nombreUsuario.equals(valor) || nombreApellido.contains(valor)
	}

	def puedeRealizarOrdenesDeInvitacion() {
		tipoDeUsuario.puedeRealizarOrdenesDeInvitacion
	}

	def agregarArtista(Artista artista) {
		artistasSeguidos.add(artista)
	}

	def sigueAlgunArtista(Evento evento) {
		evento.artistasParticipantes.exists [ artista |
			artistasSeguidos.contains(artista)
		]
	}

	@JsonIgnore
	def getActividad() {
		entradas.size + invitaciones.filter[aceptada].size + eventos.size
	}

	def obtenerAgenda() {
		val eventos = newArrayList()
		eventos.addAll(this.eventos)
		eventos.addAll(this.invitaciones.map[evento])
		eventos.addAll(this.entradas.map[evento])
		return eventos.toSet
	}

	def obtenerEventosDeInteres() {
		val eventos = newArrayList()
		eventos.addAll(eventosDelRepo.filter[sigueAlgunArtista(it)])
		eventos.addAll(eventosDelRepo.filter[algunAmigoTieneEntrada(it)])
		eventos.addAll(eventosDelRepo.filter[estaCerca(it)])
		return eventos.filter[it.esAbierto].toSet
	}

	def eventosDelRepo() {
		return ServiceLocator.instance.repoEventos.elementos
	}

	def algunAmigoTieneEntrada(Evento evento) {
		return amigos.exists[it.tieneEntrada(evento)]
	}

	def tieneEntrada(Evento evento) {
		return entradas.exists[esDeEvento(evento)]
	}

	def getCantidadAmigos() {
		amigos.size
	}

	def dispatch organizarUnEvento(EventoCerrado evento) {
		organizarEventoCerrado(evento)
	}

	def dispatch organizarUnEvento(EventoAbierto evento) {
		organizarEventoAbierto(evento)
	}

	def entradaDeEvento(Evento evento) {
		val entrada = entradas.findFirst[esDeEvento(evento)]
		if (entrada === null) {
			throw new UserException("No existe la entrada para el evento " + evento.nombre)
		}
		entrada
	}

}
