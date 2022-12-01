using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Macaron_Die : MonoBehaviour
{
    private int hp;
    private GameObject Hansel;
    // Start is called before the first frame update
    void Start()
    {
       hp = this.GetComponent<Macaron>().gHP;
        Hansel = GameObject.FindWithTag("Boss");
    }

    // Update is called once per frame
    void Update()
    {
        if (hp == 0 || Hansel.GetComponent<Hansel>().CurrentHP <= 0)
        {
            this.GetComponent<Macaron>().CutDamage();
        }

    }
}
