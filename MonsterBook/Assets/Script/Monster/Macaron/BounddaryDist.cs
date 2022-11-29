using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BounddaryDist : MonoBehaviour , IEntity
{
    public GameObject Monster;
    // Start is called before the first frame update
    void Start()
    {
           
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void OnDamage(int damage, Vector3 pos)
    {
        Monster.gameObject.GetComponent<MacaronController>().BounddaryAttack = true;
        
    }
    public void OnRecovery(int heal)
    {

    }
}
