package maven.demo;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class conexao {
    // Configurações do banco de dados
    private static final String URL = "jdbc:mysql://localhost:3306/t1?useTimezone=true&serverTimezone=UTC"; 
    private static final String USUARIO = "root";  // Usuário do MySQL
    private static final String SENHA = "";        // Senha do MySQL (deixe "" se não tiver senha)

    // Método para conectar ao banco de dados
    public static Connection conectar() {
        try {
            // Carregar o driver JDBC
            Class.forName("com.mysql.cj.jdbc.Driver");

            // Estabelecer a conexão
            Connection conexao = DriverManager.getConnection(URL, USUARIO, SENHA);
            System.out.println("✅ Conexão bem-sucedida!");
            return conexao;
        } catch (ClassNotFoundException e) {
            System.out.println("❌ Driver JDBC não encontrado!");
            e.printStackTrace();
        } catch (SQLException e) {
            System.out.println("❌ Erro ao conectar ao banco de dados!");
            e.printStackTrace();
        }
        return null;
    }

    // Método para inserir um novo usuário na tabela
    public static void inserirUsuario(int id, String nome, String sexo, int idade) {
        Connection conexao = conectar();
        if (conexao != null) {
            String sql = "INSERT INTO t11 (id, nome, sexo, idade) VALUES (?, ?, ?, ?)";

            try (PreparedStatement stmt = conexao.prepareStatement(sql)) {
                stmt.setInt(1, id);
                stmt.setString(2, nome);
                stmt.setString(3, sexo);
                stmt.setInt(4, idade);

                int linhasAfetadas = stmt.executeUpdate();
                if (linhasAfetadas > 0) {
                    System.out.println("✅ Usuário inserido com sucesso!");
                } else {
                    System.out.println("❌ Falha ao inserir usuário.");
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    public static void lerUsuario(int id) {
        Connection conexao = conectar();
        if (conexao != null) {
            String sql = "SELECT * FROM t11 WHERE id = ?";

            try (PreparedStatement stmt = conexao.prepareStatement(sql)) {
                stmt.setInt(1, id);
                ResultSet rs = stmt.executeQuery();

                if (rs.next()) {
                    String nome = rs.getString("nome");
                    String sexo = rs.getString("sexo");
                    int idade = rs.getInt("idade");

                    System.out.println("📌 ID: " + id + " | Nome: " + nome + " | Sexo: " + sexo + " | Idade: " + idade);
                } else {
                    System.out.println("⚠ Usuário com ID " + id + " não encontrado.");
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    public static void atualizarUsuario(int id, String novoNome, String novoSexo, int novaIdade) {
        Connection conexao = conectar();
        if (conexao != null) {
            String sql = "UPDATE t11 SET nome = ?, sexo = ?, idade = ? WHERE id = ?";

            try (PreparedStatement stmt = conexao.prepareStatement(sql)) {
                stmt.setString(1, novoNome);
                stmt.setString(2, novoSexo);
                stmt.setInt(3, novaIdade);
                stmt.setInt(4, id);

                int linhasAfetadas = stmt.executeUpdate();
                if (linhasAfetadas > 0) {
                    System.out.println("✅ Usuário ID " + id + " atualizado com sucesso!");
                } else {
                    System.out.println("❌ Nenhuma atualização realizada. Verifique o ID.");
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    public static void deletarUsuario(int id) {
        Connection conexao = conectar();
        if (conexao != null) {
            String sql = "DELETE FROM t11 WHERE id = ?";

            try (PreparedStatement stmt = conexao.prepareStatement(sql)) {
                stmt.setInt(1, id);

                int linhasAfetadas = stmt.executeUpdate();
                if (linhasAfetadas > 0) {
                    System.out.println("🗑 Usuário ID " + id + " deletado com sucesso!");
                } else {
                    System.out.println("⚠ Nenhum usuário encontrado com ID " + id);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    // Método para listar os dados da tabela
    public static void listarUsuarios() {
        Connection conexao = conectar();
        if (conexao != null) {
            String sql = "SELECT * FROM t11"; // Nome correto da tabela

            try (PreparedStatement stmt = conexao.prepareStatement(sql);
                 ResultSet rs = stmt.executeQuery()) {

                while (rs.next()) {
                    int id = rs.getInt("id");
                    String nome = rs.getString("nome");
                    String sexo = rs.getString("sexo");
                    int idade = rs.getInt("idade");

                    System.out.println("ID: " + id + " | Nome: " + nome + " | Sexo: " + sexo + " | Idade: " + idade);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    // Método principal para testar a inserção e leitura
    public static void main(String[] args) {
        // Inserindo usuário
        inserirUsuario(2, "Maria", "Feminino", 30);
        
        // Lendo usuário inserido
        lerUsuario(2);

        // Atualizando usuário
        atualizarUsuario(2, "Maria Silva", "Feminino", 31);
        
        // Lendo usuário atualizado
        lerUsuario(2);

        // Deletando usuário
      //  deletarUsuario(2);
listarUsuarios();
        // Tentando ler novamente para verificar se foi deletado
        lerUsuario(2);
    }

}
