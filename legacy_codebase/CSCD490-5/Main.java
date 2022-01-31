import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;

public class Main
{
	public static final float INHALE_BPM = 60;
	public static final float EXHALE_BPM = 80;
	public static final float LOW_VAR_BPM = 70;
	public static final int NUM_I_E_PAIRS = 100;
	public static final int NUM_LOW_VAR = 30;
	
	public static void main(String[] args) throws Exception
	{
		File fout = new File("out.txt");
		fout.createNewFile();
		FileWriter fw = new FileWriter(fout);
		BufferedWriter bw =  new BufferedWriter(fw);
		genTwoPer(bw);
		genOnePer(bw);
		bw.close();
	}
	
	public static float gen(float base)
	{
		return (float) (base + 6 * (Math.random() - 0.5));
	}
	
	public static void genTwoPer(BufferedWriter bw) throws Exception
	{
		for(int i = 0; i < NUM_I_E_PAIRS; i++)
		{
			bw.append("\r\n" + gen(INHALE_BPM));
			bw.append("\r\n" + gen(EXHALE_BPM));
		}
	}
	
	public static void genOnePer(BufferedWriter bw) throws Exception
	{
		for (int i = 0; i < NUM_LOW_VAR; i++)
		{
			bw.append("\r\n" + gen(LOW_VAR_BPM));
		}
	}
}
