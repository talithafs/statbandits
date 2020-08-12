package abm.agents;

import java.util.Iterator;

import abm.components.Contract;
import abm.components.Rate;
import abm.helpers.Constants;
import cern.jet.random.Uniform;
import repast.simphony.random.RandomHelper;
import repast.simphony.util.collections.IndexedIterable;

public class Sage extends Agent {
	
	private static Sage sage = null; 
	
	private double percBandits = 0 ;
	private double banditsMeanIncome = 0 ;
	
	private Contract lastContract = new Contract(0,0,0,0) ;
	private int governmentType = Constants.Vote.ANARCHY ;
	
	private double percVotesBandits = 0 ;
	private double percVotesFarmers = 0 ;
	
	private double meanBeta = -1 ; 
	  
    private Sage() { } 

    public void updateRate(int nBandits, int nForagers, double popSize) {
		
		if(nBandits != 0) {
			this.percBandits = nBandits/popSize ;
		} else {
			this.percBandits = 0 ;
		}
		
		Rate.calculate(this.percBandits);
    }
    
    
    public void updateMeans(IndexedIterable<Agent> bandits, IndexedIterable<Agent> farmers) {
    	
		double nBandits = bandits.size();
		Iterator<Agent> itrBandits = bandits.iterator();
		
		double sumBandits = 0;
		
		while(itrBandits.hasNext()) {
			Bandit bandit = (Bandit) itrBandits.next() ;
			sumBandits += bandit.getIncome() ;
		}
		
		if(nBandits != 0) {
			this.banditsMeanIncome = sumBandits/nBandits ;
		} else {
			this.banditsMeanIncome = 0 ;
		}
		
		this.updateMeanBeta(farmers);
		
    }
    
    public double getMeanBeta() {
    	return this.meanBeta ; 
    }
    
  
    public static final Sage getInstance() { 
        if(sage == null) 
            sage = new Sage(); 
  
        return sage ; 
    }
    
    public double getRate() {
    	return Rate.getRate() ;
    }

	public double getBanditsMeanIncome() {
		return this.banditsMeanIncome;
	}
	

	public final Contract proposeContract(double prodAdv, int nBandits, int nFarmers, int nForagers, double forInc){

		double rate = Rate.getRate() ;
		double p_rate = 0 ;
		
		if(rate < 0.9) {
			Uniform runif = RandomHelper.createUniform(0, 0.1);
			p_rate = rate + runif.nextDouble() ;
		} else {
			p_rate = rate ;
		}

		double rpf = p_rate / nFarmers  ;
		double rpb = (p_rate / nBandits) * nFarmers ;
		double stax = forInc*nForagers / nFarmers ;
		
		this.lastContract = new Contract(rpf, p_rate, rpb, stax);
		return lastContract ; 
	}
	
	public final int countVotes(IndexedIterable<Agent> bandits, IndexedIterable<Agent> farmers) {
		
		Iterator<Agent> itrFarmers = farmers.iterator();
		Iterator<Agent> itrBandits = bandits.iterator();
		
		double sumFarmers = 0 ;
		double sumBandits = 0 ;
		
		while(itrFarmers.hasNext()) {
			Farmer farmer = (Farmer) itrFarmers.next() ;
			sumFarmers += farmer.getVote() ;
		}
		
		while(itrBandits.hasNext()) {
			Bandit bandit = (Bandit) itrBandits.next() ;
			sumBandits += bandit.getVote() ;
		}
		
		this.percVotesBandits = sumBandits / bandits.size() ;
		this.percVotesFarmers = sumFarmers / farmers.size() ;
		
		if(sumBandits > (bandits.size()/2) && sumFarmers > (farmers.size()/2)) {
			this.governmentType = Constants.Vote.HIERARCHY ;
			return Constants.Vote.HIERARCHY ;
			
		} else {
			this.governmentType = Constants.Vote.ANARCHY ;
			return Constants.Vote.ANARCHY ;
		}

	}
	
	public final double getRatePerBandit() {
		return lastContract.getBanditsMultiplier() ;
	}
	
	public final int getGovType() {
		return governmentType ;
	}
	
	public final double getProposedRate() {
		return lastContract.getProposedRate() ;
	}
	
	public final double getSecurityTax() {
		return lastContract.getSecTax();
	}
	
	public final double getRatePerFarmer(){
		return lastContract.getRatePerFarmer() ;
	}

	public double getPercVotesBandits() {
		return percVotesBandits;
	}

	public double getPercVotesFarmers() {
		return percVotesFarmers;
	}
	
	 public void resetVariables(int nFarmers) {
	    	this.percBandits = 0 ;
	    	this.banditsMeanIncome = 0 ;
	    	
	    	this.lastContract = new Contract(0,0,0,0) ;
	    	this.governmentType = Constants.Vote.ANARCHY ;
	    	
	    	this.percVotesBandits = 0 ;
	    	this.percVotesFarmers = 0 ;
	    	
	    	this.meanBeta = -1 ; 
	    }

	public double updateMeanBeta(IndexedIterable<Agent> farmers) {
		
		Iterator<Agent> itrFarmers = farmers.iterator();
		
		double sumBetas = 0;
		
		while(itrFarmers.hasNext()) {
			Farmer farmer = (Farmer) itrFarmers.next() ;
			sumBetas += farmer.getIncome() ;
		}
		
		this.meanBeta = sumBetas / farmers.size() ;
		
		return this.meanBeta ;
		
	}

}
