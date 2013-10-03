import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.types.FileSet;
import org.apache.tools.ant.DirectoryScanner;

import javax.net.ssl.*;
import java.util.Vector;
import java.util.Iterator;
import java.io.*;
import java.security.KeyStore;
import java.security.MessageDigest;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;

public class AddCertTask extends Task {

    private String host;
    private String storeFile;
    private int port;
    private char[] passphrase;
    private Vector filesets = new Vector();
    
    public void setHost(String host) {
        this.host = host;
    }

    public void setPort(int port) {
    	this.port = port;
    }
    
    public void setPassphrase(String passphrase) {
    	this.passphrase = passphrase.toCharArray();
    }
    
    public void addFileset(FileSet fileset) {
    	filesets.add(fileset);
    }
    
    // The method executing the task
    public void execute() throws BuildException {
    	for(Iterator itFSets = filesets.iterator(); itFSets.hasNext(); ) {      // 2
            FileSet fs = (FileSet)itFSets.next();
            DirectoryScanner ds = fs.getDirectoryScanner(getProject());         // 3
            String[] includedFiles = ds.getIncludedFiles();
            for(int i=0; i<includedFiles.length; i++) {
            	try {
                    File base  = ds.getBasedir();                               // 5
                    File found = new File(base, includedFiles[i]);
            		addCert(host,port,found.getAbsolutePath());
            	} catch (Exception e) {
            		throw new BuildException(e);
            	}
            }
        }
    	
    }

    private void addCert(String host, int port, String storeFile) throws Exception {
        File file = new File(storeFile);
        if (file.isFile() == false) {
            System.out.println("Could not find:"+storeFile);
            return;
            /*
        	char SEP = File.separatorChar;
            File dir = new File(System.getProperty("java.home") + SEP
                    + "lib" + SEP + "security");
            file = new File(dir, "jssecacerts");
            if (file.isFile() == false) {
                file = new File(dir, "cacerts");
            }
             */
        }
        if(this.passphrase == null) {
        	System.out.println("Using default store password of 'changeit'");
        	setPassphrase("changeit");
        }
        System.out.println("Loading KeyStore " + file + "...");
        InputStream in = new FileInputStream(file);
        KeyStore ks = KeyStore.getInstance(KeyStore.getDefaultType());
        ks.load(in, passphrase);
        in.close();

        SSLContext context = SSLContext.getInstance("TLS");
        TrustManagerFactory tmf =
                TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
        tmf.init(ks);
        X509TrustManager defaultTrustManager = (X509TrustManager) tmf.getTrustManagers()[0];
        SavingTrustManager tm = new SavingTrustManager(defaultTrustManager);
        context.init(null, new TrustManager[]{tm}, null);
        SSLSocketFactory factory = context.getSocketFactory();

        System.out.println("Opening connection to " + host + ":" + port + "...");
        SSLSocket socket = (SSLSocket) factory.createSocket(host, port);
        socket.setSoTimeout(10000);
        try {
            System.out.println("Starting SSL handshake...");
            socket.startHandshake();
            socket.close();
            System.out.println();
            System.out.println("No errors, certificate is already trusted");
            return;
        } catch (SSLException e) {
            System.out.println();
            //e.printStackTrace(System.out);
        }

        X509Certificate[] chain = tm.chain;
        if (chain == null) {
            System.out.println("Could not obtain server certificate chain");
            return;
        }

        BufferedReader reader =
                new BufferedReader(new InputStreamReader(System.in));

        System.out.println();
        System.out.println("Server sent " + chain.length + " certificate(s):");
        System.out.println();
        MessageDigest sha1 = MessageDigest.getInstance("SHA1");
        MessageDigest md5 = MessageDigest.getInstance("MD5");
        for (int i = 0; i < chain.length; i++) {
            X509Certificate cert = chain[i];
            System.out.println
                    (" " + (i + 1) + " Subject " + cert.getSubjectDN());
            System.out.println("   Issuer  " + cert.getIssuerDN());
            sha1.update(cert.getEncoded());
            System.out.println("   sha1    " + toHexString(sha1.digest()));
            md5.update(cert.getEncoded());
            System.out.println("   md5     " + toHexString(md5.digest()));
            System.out.println();

            String alias = host + "-" + (i + 1);
            ks.setCertificateEntry(alias, cert);
            System.out.println();
            //System.out.println(cert);
            System.out.println
                    ("Added certificate to keystore '"+file.getAbsolutePath() + "' using alias '"
                            + alias + "'");
        }
        OutputStream out = new FileOutputStream(file);
        ks.store(out, passphrase);
        out.close();
    }

    private static final char[] HEXDIGITS = "0123456789abcdef".toCharArray();

    private static String toHexString(byte[] bytes) {
        StringBuilder sb = new StringBuilder(bytes.length * 3);
        for (int b : bytes) {
            b &= 0xff;
            sb.append(HEXDIGITS[b >> 4]);
            sb.append(HEXDIGITS[b & 15]);
            sb.append(' ');
        }
        return sb.toString();
    }

    private static class SavingTrustManager implements X509TrustManager {

        private final X509TrustManager tm;
        private X509Certificate[] chain;

        SavingTrustManager(X509TrustManager tm) {
            this.tm = tm;
        }

        public X509Certificate[] getAcceptedIssuers() {
            throw new UnsupportedOperationException();
        }

        public void checkClientTrusted(X509Certificate[] chain, String authType)
                throws CertificateException {
            throw new UnsupportedOperationException();
        }

        public void checkServerTrusted(X509Certificate[] chain, String authType)
                throws CertificateException {
            this.chain = chain;
            tm.checkServerTrusted(chain, authType);
        }
    }

}