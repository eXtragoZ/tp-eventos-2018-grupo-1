package edu.algo2.eventos.config

import org.eclipse.xtend.lib.annotations.Accessors
import edu.algo2.repositorio.RepoUsuarios
import edu.algo2.repositorio.RepoLocaciones
import edu.algo2.repositorio.RepoServicios
import edu.algo2.repositorio.RepoEventos

@Accessors
class ServiceLocator {

	RepoUsuarios repoUsuarios
	RepoLocaciones repoLocaciones
	RepoServicios repoServicios
	RepoEventos repoEventos

	static ServiceLocator instance

	private new() {
		repoUsuarios = new RepoUsuarios
		repoLocaciones = new RepoLocaciones
		repoServicios = new RepoServicios
		repoEventos = new RepoEventos
	}

	def static getInstance() {
		if (instance === null) {
			instance = new ServiceLocator
		}
		instance
	}

}
