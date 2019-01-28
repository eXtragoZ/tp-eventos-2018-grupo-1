package edu.algo2.eventos

import edu.algo2.eventos.excepciones.RepositorioException
import edu.algo2.eventos.excepciones.ValidacionException
import edu.algo2.repositorio.RepoLocaciones
import edu.algo2.repositorio.RepoServicios
import edu.algo2.repositorio.RepoUsuarios
import java.time.LocalDate
import java.time.temporal.ChronoUnit
import org.json.simple.JSONArray
import org.json.simple.JSONObject
import org.junit.Before
import org.junit.Test
import org.uqbar.geodds.Point
import static org.mockito.Mockito.*

import static org.junit.Assert.*
import org.uqbar.updateService.UpdateService
import java.time.LocalDateTime
import org.uqbar.mailService.MailService
import org.uqbar.mailService.Mail

class RepositorioTest {

	RepoUsuarios repoUsuarios
	RepoLocaciones repoLocaciones
	RepoServicios repoServicios
	Usuario usuario
	Usuario usuarioCopia
	Locacion locacion
	Servicio servicio
	Servicio servicioTarifaPorHora
	Servicio servicioTarifaPorPersona
	JSONObject jsonUsuario1
	JSONObject jsonUsuario2
	JSONObject jsonLocacion1
	JSONObject jsonLocacion2
	JSONObject jsonServicio1
	JSONObject jsonServicio2
	JSONObject jsonServicio3
	JSONArray jsonUsuarios
	JSONArray jsonLocaciones
	JSONArray jsonServicios
	String jsonListaUsuarios
	String jsonListaLocaciones
	String jsonListaServicios
	EventoCerrado eventoCerrado
	EventoAbierto eventoAbierto

	var servicioActualizacionMock = mock(UpdateService)

	@Before
	def void init() {
		repoUsuarios = new RepoUsuarios
		repoLocaciones = new RepoLocaciones
		repoServicios = new RepoServicios

		jsonUsuario1 = new JSONObject() => [
			put("nombreUsuario", "lucas_capo")
			put("nombreApellido", "Lucas Lopez")
			put("email", "lucas_93@hotmail.com")
			put("fechaNacimiento", "15/01/1993")
			put("direccion", new JSONObject() => [
				put("calle", "25 de Mayo")
				put("numero", 3918)
				put("localidad", "San Martín")
				put("provincia", "Buenos Aires")
				put("coordenadas", new JSONObject() => [
					put("x", -34.572224)
					put("y", 58.535651)
				])
			])
		]

		jsonUsuario2 = new JSONObject() => [
			put("nombreUsuario", "martin1990")
			put("nombreApellido", "Martín Varela")
			put("email", "martinvarela90@yahoo.com")
			put("fechaNacimiento", "18/11/1990")
			put("direccion", new JSONObject() => [
				put("calle", "Av. Triunvirato")
				put("numero", 4065)
				put("localidad", "CABA")
				put("provincia", "")
				put("coordenadas", new JSONObject() => [
					put("x", -33.582360)
					put("y", 60.516598)
				])
			])
		]

		jsonUsuarios = new JSONArray() => [
			add(jsonUsuario1)
			add(jsonUsuario2)
		]

		jsonListaUsuarios = jsonUsuarios.toString

		jsonLocacion1 = new JSONObject() => [
			put("x", -34.603759)
			put("y", -58.381586)
			put("nombre", "Salón El Abierto")
		]

		jsonLocacion2 = new JSONObject() => [
			put("x", -34.572224)
			put("y", -58.535651)
			put("nombre", "Estadio Obras")
		]

		jsonLocaciones = new JSONArray() => [
			add(jsonLocacion1)
			add(jsonLocacion2)
		]

		jsonListaLocaciones = jsonLocaciones.toString

		jsonServicio1 = new JSONObject() => [
			put("descripcion", "Catering Food Party")
			put("tarifaServicio", new JSONObject() => [
				put("tipo", "TF")
				put("valor", 5000.00)
			])
			put("tarifaTraslado", 30.00)
			put("ubicacion", new JSONObject() => [
				put("x", -34.572224)
				put("y", 58.535651)
			])
		]

		jsonServicio2 = new JSONObject() => [
			put("descripcion", "Test TPP")
			put("tarifaServicio", new JSONObject() => [
				put("tipo", "TPP")
				put("valor", 300.00)
				put("porcentajeParaMinimo", 70)
			])
			put("tarifaTraslado", 30.00)
			put("ubicacion", new JSONObject() => [
				put("x", -34.572224)
				put("y", 58.535651)
			])
		]

		jsonServicio3 = new JSONObject() => [
			put("descripcion", "Test TPH")
			put("tarifaServicio", new JSONObject() => [
				put("tipo", "TPH")
				put("valor", 1000.00)
				put("minimo", 3500.00)
			])
			put("tarifaTraslado", 30.00)
			put("ubicacion", new JSONObject() => [
				put("x", -34.572224)
				put("y", 58.535651)
			])
		]

		jsonServicios = new JSONArray() => [
			add(jsonServicio1)
			add(jsonServicio2)
			add(jsonServicio3)
		]

		jsonListaServicios = jsonServicios.toString

		usuario = new Usuario("lucas_capo", new TipoUsuarioFree) => [
			fechaNacimiento = LocalDate.now.minus(25, ChronoUnit.YEARS)
			direccion = new Point(-35, -60)
			nombreApellido = "nombre y apellido"
			email = "el Email"
			radioCercania = 10000.0
		]

		usuarioCopia = new Usuario("lucas_capo", new TipoUsuarioAmateur) => [
			fechaNacimiento = LocalDate.now.minus(24, ChronoUnit.YEARS)
			direccion = new Point(-34.1, -51.1)
			nombreApellido = "otro nombre y apellido copia"
			email = "otro Email"
			radioCercania = 50.0
		]

		locacion = new Locacion("Salón El Abierto", -34, -51, 100.0)

		servicio = new Servicio("Catering Food Party", new Point(-34, -51), 1000.0) => [
			tipoTarifa = new TarifaFija
		]
		
		servicioTarifaPorHora = new Servicio("Test TPH", new Point(-34, -51), 1000.0) => [
			tipoTarifa = new TarifaPorHora
		]
		
		servicioTarifaPorPersona = new Servicio("Test TPP", new Point(-34, -51), 1000.0) => [
			tipoTarifa = new TarifaPorPersona => [
				porcentajeMinimo = 0.1
			]
		]
		
		eventoCerrado = new EventoCerrado("La Fiesta Privada", locacion) => [
			fechaConfirmacion = LocalDateTime.now.plus(10, ChronoUnit.DAYS)
			fechaDesde = LocalDateTime.now.plus(16, ChronoUnit.DAYS)
			fechaHasta = LocalDateTime.now.plus(18, ChronoUnit.DAYS).minus(1, ChronoUnit.HOURS)
			capacidadMaxima = 10
			organizador = usuario
		]
		
		eventoAbierto = new EventoAbierto("La Fiesta Privada", locacion) => [
			fechaConfirmacion = LocalDateTime.now.plus(10, ChronoUnit.DAYS)
			fechaDesde = LocalDateTime.now.plus(16, ChronoUnit.DAYS)
			fechaHasta = LocalDateTime.now.plus(18, ChronoUnit.DAYS).minus(1, ChronoUnit.HOURS)
			organizador = usuario
		]
	}

	@Test
	def void reciboUnJsonConNuevosUsuarios() {
		repoUsuarios.procesarListaJson(jsonListaUsuarios)
		assertEquals("Lucas Lopez", repoUsuarios.elementos.get(0).nombreApellido)
	}

	@Test
	def void reciboUnJsonConUsuarioExistente() {
		repoUsuarios.create(usuario)
		repoUsuarios.procesarListaJson(jsonListaUsuarios)
		assertEquals("Lucas Lopez", repoUsuarios.elementos.get(0).nombreApellido)
	}

	@Test
	def void reciboUnJsonConNuevasLocaciones() {
		repoLocaciones.procesarListaJson(jsonListaLocaciones)
		assertEquals("Salón El Abierto", repoLocaciones.elementos.get(0).nombre)
	}

	@Test
	def void reciboUnJsonConLocacionExistente() {
		repoLocaciones.create(locacion)
		repoLocaciones.procesarListaJson(jsonListaLocaciones)
		assertEquals(-58.381586, repoLocaciones.elementos.get(0).ubicacion.longitude, 0)
	}

	@Test
	def void reciboUnJsonConNuevosServicios() {
		repoServicios.procesarListaJson(jsonListaServicios)
		assertEquals("Catering Food Party", repoServicios.elementos.get(0).descripcion)
	}

	@Test
	def void reciboUnJsonConServicioExistente() {
		repoServicios.create(servicio)
		repoServicios.procesarListaJson(jsonListaServicios)
		assertEquals(30.00, repoServicios.elementos.get(0).tarifaPorKm, 0)
	}

	@Test
	def void reciboUnJsonConServicioConTarifaPorHoraExistente() {
		repoServicios.create(servicioTarifaPorHora)
		repoServicios.procesarListaJson(jsonListaServicios)
		assertEquals(TarifaPorHora, ((repoServicios.elementos.get(0) as Servicio).tipoTarifa).class)
	}

	@Test
	def void reciboUnJsonConServicioConTarifaPorPersonaExistente() {
		repoServicios.create(servicioTarifaPorPersona)
		repoServicios.procesarListaJson(jsonListaServicios)
		assertEquals(TarifaPorPersona, ((repoServicios.elementos.get(0) as Servicio).tipoTarifa).class)
	}

	@Test
	def void creoUnUsuario() {
		repoUsuarios.create(usuario)
		assertEquals("nombre y apellido", repoUsuarios.elementos.get(0).nombreApellido)
	}

	@Test
	def void creoUnaLocacion() {
		repoLocaciones.create(locacion)
		assertEquals("Salón El Abierto", repoLocaciones.elementos.get(0).nombre)
	}

	@Test
	def void creoUnServicio() {
		repoServicios.create(servicio)
		assertEquals("Catering Food Party", repoServicios.elementos.get(0).descripcion)
	}

	@Test
	def void eliminoUnUsuario() {
		repoUsuarios.create(usuario)
		repoUsuarios.delete(usuarioCopia => [id = usuario.id])
		assertEquals(0, repoUsuarios.elementos.size)
	}

	@Test
	def void actualizoUnUsuario() {
		repoUsuarios.create(usuario)
		repoUsuarios.update(usuarioCopia => [id = usuario.id])
		assertEquals("otro nombre y apellido copia", repoUsuarios.elementos.get(0).nombreApellido)
	}

	@Test
	def void buscoUnUsuarioPorId() {
		repoUsuarios.create(usuario)
		val usuarioResultado = repoUsuarios.searchById(usuario.id)
		assertEquals(usuario, usuarioResultado)
	}

	@Test(expected=RepositorioException)
	def void buscoUnUsuarioPorIdNoExisteTiraExcepcion() {
		repoUsuarios.searchById(1)
	}

	@Test
	def void buscoUsuarios() {
		repoUsuarios.create(usuario)
		repoUsuarios.create(usuarioCopia)
		val usuariosResultado = repoUsuarios.search("copia")
		assertEquals(1, usuariosResultado.size)
	}

	@Test(expected=ValidacionException)
	def void alCrearUsuarioSinAliasTiraExepcion() {
		jsonUsuario1.remove("nombreUsuario")
		var array = new JSONArray() => [
			add(jsonUsuario1)
		]
		repoUsuarios.procesarListaJson(array.toString)
	}

	@Test(expected=ValidacionException)
	def void alCrearUsuarioSinNombreTiraExepcion() {
		jsonUsuario1.remove("nombreApellido")
		var array = new JSONArray() => [
			add(jsonUsuario1)
		]
		repoUsuarios.procesarListaJson(array.toString)
	}

	@Test(expected=ValidacionException)
	def void alCrearUsuarioSinEmailNombreTiraExepcion() {
		jsonUsuario1.remove("email")
		var array = new JSONArray() => [
			add(jsonUsuario1)
		]
		repoUsuarios.procesarListaJson(array.toString)
	}

	@Test
	def void actualizacionDeRepositorioDeUsuariosConServicioDeActualizacion() {
		when(servicioActualizacionMock.getUserUpdates).thenReturn(jsonListaUsuarios)
		repoUsuarios.servicioActualizacion = servicioActualizacionMock
		repoUsuarios.updateAll
		assertEquals(2, repoUsuarios.elementos.size, 0)
	}

	@Test
	def void actualizacionDeRepositorioDeLocacionesConServicioDeActualizacion() {
		when(servicioActualizacionMock.getLocationUpdates).thenReturn(jsonListaLocaciones)
		repoLocaciones.servicioActualizacion = servicioActualizacionMock
		repoLocaciones.updateAll
		assertEquals(2, repoLocaciones.elementos.size, 0)
	}

	@Test
	def void actualizacionDeRepositorioDeServiciosConServicioDeActualizacion() {
		when(servicioActualizacionMock.getServiceUpdates).thenReturn(jsonListaServicios)
		repoServicios.servicioActualizacion = servicioActualizacionMock
		repoServicios.updateAll
		assertEquals(3, repoServicios.elementos.size, 0)
	}

	@Test
	def void elUsuarioNotificaAmigosAlCrearEvento() {
		usuario.amigos.add(usuarioCopia)
		usuario.notificacionObservers.add(new NotificarAmigosObserver)
		usuario.organizarEventoCerrado(eventoCerrado)
		assertEquals(1, usuarioCopia.notificaciones.size, 0)
	}
	
	@Test
	def void elUsuarioNotificaUsuariosQueLoTienenDeAmigoAlCrearEvento() {
		repoUsuarios.create(usuarioCopia)
		usuarioCopia.amigos.add(usuario)
		usuario.notificacionObservers.add(new NotificarUsuariosConOrganizadorAmigoObserver => [
			it.repoUsuarios = repoUsuarios
			it.servicioMail = mock(MailService)
		])
		usuario.organizarEventoCerrado(eventoCerrado)
		assertEquals(1, usuarioCopia.notificaciones.size, 0)
	}
	
	@Test
	def void elUsuarioNotificaUsuariosQueLoTienenDeAmigoYQueVivenCercaAlCrearEvento() {
		repoUsuarios.create(usuarioCopia)
		usuarioCopia.amigos.add(usuario)
		usuario.notificacionObservers.add(new NotificarContactosCercanosObserver => [
			it.repoUsuarios = repoUsuarios
			it.servicioMail = mock(MailService)
		])
		usuario.organizarEventoCerrado(eventoCerrado)
		assertEquals(1, usuarioCopia.notificaciones.size, 0)
	}
	
	@Test
	def void elUsuarioNotificaUsuariosAmigosQueVivenCercaAlCrearEvento() {
		usuario.amigos.add(usuarioCopia)
		usuario.notificacionObservers.add(new NotificarContactosCercanosObserver => [
			it.repoUsuarios = repoUsuarios
			it.servicioMail = mock(MailService)
		])
		usuario.organizarEventoCerrado(eventoCerrado)
		assertEquals(1, usuarioCopia.notificaciones.size, 0)
	}
	
	@Test
	def void elUsuarioNotificaUsuariosQueVivenCercaAlCrearEvento() {
		repoUsuarios.create(usuario)
		usuarioCopia.notificacionObservers.add(new NotificarUsuariosCercanosObserver => [
			it.repoUsuarios = repoUsuarios
			it.servicioMail = mock(MailService)
		])
		usuarioCopia.organizarEventoAbierto(eventoAbierto)
		assertEquals(1, usuario.notificaciones.size, 0)
	}
	
	@Test
	def void elUsuarioNotificaFansDelArtistaAlCrearEvento() {
		var Artista artista = new Artista("Luismi")
		repoUsuarios.create(usuario)
		usuario.agregarArtista(artista)
		eventoAbierto.artistasParticipantes().add(artista)
		var observer = new NotificarFansDelArtistaObserver => [
			it.repoUsuarios = repoUsuarios
			it.servicioMail = mock(MailService)
		]
		usuarioCopia.notificacionObservers.add(observer)
		usuarioCopia.organizarEventoAbierto(eventoAbierto)
		
		verify(observer.servicioMail, times(1)).sendMail(any(Mail))
	}
	
}
