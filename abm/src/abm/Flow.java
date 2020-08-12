package abm;

//-Xmx32g -Xms32g -Xss32g 

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Iterator;

import abm.agents.Agent;
import abm.agents.Bandit;
import abm.agents.Farmer;
import abm.agents.Forager;
import abm.agents.NonFarmer;
import abm.agents.Sage;
import abm.components.Contract;
import abm.components.MetaParameters;
import abm.helpers.Constants;
import repast.simphony.context.Context;
import repast.simphony.engine.environment.RunEnvironment;
import repast.simphony.engine.schedule.ScheduledMethod;
import repast.simphony.util.collections.IndexedIterable;

public final class Flow {

	private static Context<Agent> context = null ;
	private static MetaParameters params = null ;
	private static boolean switched = false ;
	
	public static void init(Context<Agent> context, MetaParameters params) {
		Flow.context = context ;
		Flow.params = params ;
	}
	
	@ScheduledMethod(start = 1, interval = 1)
	public static void run() throws NoSuchMethodException, SecurityException {
		
		double tick = RunEnvironment.getInstance().getCurrentSchedule().getTickCount() ;

		IndexedIterable<Agent> farmers = context.getObjects(Farmer.class);
		IndexedIterable<Agent> foragers = context.getObjects(Forager.class);
		IndexedIterable<Agent> bandits = context.getObjects(Bandit.class);
		IndexedIterable<Agent> nonFarmers = context.getObjects(NonFarmer.class);
		
		Sage sage = Sage.getInstance() ;
		
		if(sage.getGovType() == Constants.Vote.ANARCHY) {
			
			double rate = sage.getRate() ;
						
			iterate(nonFarmers, NonFarmer.class.getMethod("chooseTarget", getArgs(1,IndexedIterable.class)), farmers);
			separateNonFarmers(nonFarmers, rate, params.getForagersIncome());
			
			foragers = context.getObjects(Forager.class);
			bandits = context.getObjects(Bandit.class);
			
			sage.updateRate(bandits.size(), foragers.size(), params.getPopulationSize());
			rate = sage.getRate() ;

			iterate(bandits, Bandit.class.getMethod("steal", getArgs(1,double.class)), rate);
			iterate(foragers, Forager.class.getMethod("receiveIncome",getArgs(1,double.class)), params.getForagersIncome());
			
			iterate(farmers, Farmer.class.getMethod("receiveIncome",getArgs(3,double.class)), rate, params.getProdAdvantage(), 0);
			iterate(farmers, Farmer.class.getMethod("chooseAction",getArgs(3,double.class)), rate, params.getProdAdvantage(), 0);
		
			if(tick % 5 == 0 && bandits.size() != 0) {
				
				sage.updateMeans(bandits, farmers);
			
				Contract contract = sage.proposeContract(params.getProdAdvantage(), bandits.size(), farmers.size(), foragers.size(), params.getForagersIncome());
				iterate(farmers, Farmer.class.getMethod("vote",getArgs(3,double.class)), contract.getRatePerFarmer(), params.getProdAdvantage(), contract.getSecTax());
				iterate(bandits, Bandit.class.getMethod("vote",getArgs(2,double.class)), sage.getMeanBeta(), contract.getBanditsMultiplier());		
				sage.countVotes(bandits, farmers);
			}
			
			iterate(farmers, Farmer.class.getMethod("resetStolen"));
			
			return ;
			
		} else {
			
			if(!switched) {
				iterate(farmers, Farmer.class.getMethod("setTaxPayer"));
				switched = true ;
			}
			
			iterate(farmers, Farmer.class.getMethod("chooseAction",getArgs(3,double.class)), sage.getRatePerFarmer(), params.getProdAdvantage(), sage.getSecurityTax());
			iterate(farmers, Farmer.class.getMethod("receiveIncome",getArgs(3,double.class)), sage.getRatePerFarmer(), params.getProdAdvantage(), sage.getSecurityTax());
			
			sage.updateMeanBeta(farmers);
			
			iterate(bandits, Bandit.class.getMethod("receiveIncome",getArgs(2,double.class)), sage.getRatePerBandit(), sage.getMeanBeta());
			iterate(foragers, Forager.class.getMethod("receiveIncome",getArgs(1,double.class)), params.getForagersIncome());
		}

	}
	
	private static void separateNonFarmers(IndexedIterable<Agent> nonFarmers, double rate, double meanIncome) {
		
		Iterator<Agent> itr = nonFarmers.iterator();
		ArrayList<NonFarmer> remv = new ArrayList<NonFarmer>();
		ArrayList<Bandit> bandits = new ArrayList<Bandit>();
		ArrayList<Forager> foragers = new ArrayList<Forager>();
		
		while(itr.hasNext()) {
			
			NonFarmer nonFarmer = (NonFarmer) itr.next() ;
			int choice = nonFarmer.chooseAction(rate, meanIncome, params.getProdAdvantage());
			NonFarmer changedNonFarmer = null ;
			
			if(nonFarmer instanceof Bandit && choice == Constants.Status.FORAGER) {
				
				changedNonFarmer = new Forager(nonFarmer.getIncome());
				foragers.add((Forager) changedNonFarmer);
				remv.add(nonFarmer);
				
			} else if(nonFarmer instanceof Forager && choice == Constants.Status.BANDIT) {
				
				changedNonFarmer = new Bandit(nonFarmer.getIncome(), nonFarmer.getTarget());
				bandits.add((Bandit) changedNonFarmer);
				remv.add(nonFarmer);
			} 		
		}
		
		context.addAll(bandits);
		context.addAll(foragers);
		context.removeAll(remv);
	}
	
	private static void iterate(IndexedIterable<Agent> agents, Method method, Object ... args)  {
		
		Iterator<Agent> itr = agents.iterator() ;
		
		while(itr.hasNext()) {
			try {
				if(args.length == 0) {
					method.invoke(itr.next());
				}
				else {
					method.invoke(itr.next(), args);
				}
			} catch (IllegalAccessException | IllegalArgumentException | InvocationTargetException e) {
				e.printStackTrace();
			}
		}
		
	}
	
	@SuppressWarnings("rawtypes")
	private static Class[] getArgs(int size, Class aClass) {
		
		Class[] args = new Class[size];
		
		for (int i = 0; i < size; ++i) {
			args[i] = aClass ;
		}
		
		return args ;
	}
	
}
