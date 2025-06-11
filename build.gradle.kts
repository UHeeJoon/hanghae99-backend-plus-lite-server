plugins {
	java
	id("org.springframework.boot") version "3.4.1"
	id("io.spring.dependency-management") version "1.1.7"
}

java {
	toolchain {
		languageVersion = JavaLanguageVersion.of(17)
	}
}

fun getGitHash(): String {
	return providers.exec {
		commandLine("git", "rev-parse", "--short", "HEAD")
	}.standardOutput.asText.get().trim()
}

allprojects {

	group = "kr.hhplus.be"
	version = getGitHash()

	repositories {
		mavenCentral()
	}

}

subprojects {

	apply(plugin = "java")
	apply(plugin = "org.springframework.boot")
	apply(plugin = "io.spring.dependency-management")


	java {
		sourceCompatibility = JavaVersion.VERSION_17
	}

	dependencyManagement {
		imports {
			mavenBom("org.springframework.cloud:spring-cloud-dependencies:2024.0.0")
		}
	}

	dependencies {
		// Spring
		implementation("org.springframework.boot:spring-boot-starter-actuator")
		implementation("org.springframework.boot:spring-boot-starter-data-jpa")
		implementation("org.springframework.boot:spring-boot-starter-web")

		// lombok
		implementation("org.projectlombok:lombok")
		annotationProcessor("org.projectlombok:lombok")

		// Test
		testRuntimeOnly("org.junit.platform:junit-platform-launcher")
	}

	tasks.withType<Test> {
		useJUnitPlatform()
		systemProperty("user.timezone", "UTC")
	}

}
