package abm;

import java.util.ArrayList;

import abm.Flow;
import abm.agents.Agent;
import abm.agents.Farmer;
import abm.agents.NonFarmer;
import abm.agents.Sage;
import abm.components.MetaParameters;
import abm.components.Rate;
import abm.creators.FarmersCreator;
import abm.creators.NonFarmersCreator;
import repast.simphony.context.Context;
import repast.simphony.dataLoader.ContextBuilder;
import repast.simphony.engine.environment.RunEnvironment;

public class Controller implements ContextBuilder<Agent>{
	
	@SuppressWarnings("unchecked")
	@Override
	public Context<Agent> build(Context<Agent> context) {
		
		context.setId("abm");

		MetaParameters metaParams = new MetaParameters();
		metaParams.init(); 
		
		double rate = Rate.calculate(metaParams) ;

		FarmersCreator farmersCreator = new FarmersCreator(metaParams, rate) ;
		ArrayList<Farmer> farmers = farmersCreator.create() ;
		context.addAll(farmers) ;
		
		NonFarmersCreator nonFarmersCreator = new NonFarmersCreator(metaParams, rate) ;
		ArrayList<NonFarmer> nonFarmers = nonFarmersCreator.create() ;
		context.addAll(nonFarmers);
		
		Sage sage = Sage.getInstance() ;
		sage.resetVariables(metaParams.getNFarmers()); 
		context.add(sage);
				
		Flow.init(context, metaParams);
		
		if (RunEnvironment.getInstance().isBatch()) {
			RunEnvironment.getInstance().endAt(100);
		}
		
		return context;
	}

}
