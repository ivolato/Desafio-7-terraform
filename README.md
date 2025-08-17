# Infraestructura en AWS con Terraform
Este proyecto tiene como objetivo la implementación de un entorno automatizado para la instalación y configuración de un sitio web basado en WordPress, utilizando Ansible como herramienta de Configuration as Code (CaC).
La solución está diseñada para ejecutarse sobre una instancia EC2 provista por AWS Academy, y busca facilitar el despliegue reproducible y modular del entorno web, incluyendo tanto el servidor web como sus dependencias.
La arquitectura planteada incluye:

Instalación y configuración de PHP junto con sus extensiones necesarias.
Instalación y configuración de MariaDB como base de datos local.
Despliegue de WordPress


Para lograr una solución mantenible y reutilizable, se emplea la estructura de roles en Ansible, permitiendo separar responsabilidades y mejorar la organización del código. Se divide de tres roles (Setup, Apache + Php + Wordpress , MySQL) a través de los que será gestionado, permitiendo escalabilidad y facilidad de mantenimiento.

## Clonar el repositorio.
```
git clone https://github.com/ivolato/Desafio-6-Ansible.git
```

## Instalamos pipx en la maquina que usaremos para gestionar con Ansible.
```
sudo apt install pipx -y
pipx ensurepath
```

## Instalamos Ansible.
```
pipx install --include-deps ansible
```

## Verificamos que se instalo correctamente Ansible.
```
ansible --version
```

## Asignarle permisos correspondientes a la key para acceder por ssh.
```
cd Desafio-6-Ansible/.ssh
chmod 600 aws.pem
```
