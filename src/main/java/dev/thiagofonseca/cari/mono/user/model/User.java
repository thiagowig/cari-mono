package dev.thiagofonseca.cari.mono.user.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Table(name="application_user")
@Data
public class User {

    @Id
    private Long id;
    private String username;
    private String password;
    private String role;
}
