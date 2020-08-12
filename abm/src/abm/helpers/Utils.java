package abm.helpers;

import java.util.ArrayList;
import java.util.Iterator;

import abm.agents.Agent;
import repast.simphony.random.RandomHelper;
import repast.simphony.util.SimUtilities;
import repast.simphony.util.collections.IndexedIterable;

public final class Utils {
	
	
	public static String getAgentDescriptor(String[][] fields, boolean showId) {
		
		StringBuilder result = new StringBuilder();
	    String newLine = System.getProperty("line.separator");
	    int i = 0 ;
		
		if(showId) {
			result.append("-- Agent " + fields[0][1] + " --");
		    result.append(newLine);
		    i = 1 ;
		}
		
		return getDescriptor(result, fields, i, newLine).toString();
		
	}
	
	public static String getLinkDescriptor(String[][] fields, String name, Agent a, Agent b) {
		
		StringBuilder result = new StringBuilder();
	    String newLine = System.getProperty("line.separator");
		
		result.append("-- " + name + " between " + a.getId() +  " and " + b.getId() + " --" );
	    result.append(newLine);

	    return getDescriptor(result, fields, 0, newLine).toString();
	}
	
	public static String getComponentDescriptor(String[][] fields, boolean showId) {
		
		StringBuilder result = new StringBuilder();
	    String newLine = System.getProperty("line.separator");
	    int i = 0 ;
	   
		
	    if(showId) {
			result.append("-- Component " + fields[0][1] + " --");
		    result.append(newLine);
		    i = 1 ;
		}
		
		return getDescriptor(result, fields, i, newLine).toString();
	}
	
	private static StringBuilder getDescriptor(StringBuilder builder, String[][] fields, int i, String newLine) {
		
		while(i < fields.length) {
			builder.append(fields[i][0] + " : " + fields[i][1]);
			builder.append(newLine);
			i++ ;
		}
		
		builder.append("-");
		builder.append(newLine);
		
		return builder ;
	}
	
	public static <T> ArrayList<T> shuffle(IndexedIterable<T> agents){
		
		ArrayList<T> shuffled = new ArrayList<T>();
		Iterator<T> itr = agents.iterator() ;
	
		while(itr.hasNext()) {
			shuffled.add(itr.next());
		}
		
		SimUtilities.shuffle(shuffled, RandomHelper.getUniform());
		
		return shuffled ;
	}
}
