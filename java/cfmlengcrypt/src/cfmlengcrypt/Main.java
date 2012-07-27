package cfmlengcrypt;

public class Main {

	public static void main(String[] args) {
		if (args.length > 1) {
			if (args[0].toLowerCase().equals("railo")) {
				RailoEncrypt.encrypt(args[1]);
			} else if (args[0].toLowerCase().equals("sha")) {
				ShaHash.encrypt(args[1]);
			} else {
				ACFDSNEncrypt.encrypt(args[1]);
			}

		} else {
			System.out.println("Usage:");
			System.out.println("java -jar cfmlengcrypt railo somepassword");
			System.out.println("java -jar cfmlengcrypt acf somepassword");
			System.out.println("java -jar cfmlengcrypt sha somepassword");
		}
	}

}