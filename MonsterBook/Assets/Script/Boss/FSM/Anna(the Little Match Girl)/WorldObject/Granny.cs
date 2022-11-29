using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Granny : MonoBehaviour
{
    // Start is called before the first frame update
    private GameObject Target;
    public float speed;
    public float RoundSpeed;
    public Renderer FrozenScreen;
    private float time;
    private float ActiveTimer;

    void Start()
    {
        Target = GameObject.FindWithTag("Player");
        FrozenScreen = GameObject.FindWithTag("FrozenScreen").GetComponent<Renderer>();
        time = 0;
        ActiveTimer = 0;

    }

    // Update is called once per frame
    void Update()
    {
        ActiveTimer += Time.deltaTime;
        if (ActiveTimer <= 10f)
        {
            //Rotate
            var m_lookatVec = (new Vector3(Target.transform.position.x, 0, 0)
                - new Vector3(transform.position.x, 0, 0)).normalized;
            transform.rotation = Quaternion.Lerp(transform.rotation,
                Quaternion.LookRotation(m_lookatVec), Time.fixedDeltaTime * RoundSpeed);

            //Move
            var _TargetTrnasform = new Vector3(Target.transform.position.x, Target.transform.position.y + 1.5f, Target.transform.position.z);
            transform.position = Vector3.MoveTowards(transform.position, _TargetTrnasform, speed);
        }

        else
        {
            Destroy(this.gameObject);
        }

    }

    private void OnTriggerStay(Collider other)
    {
        if(other.tag == "Player")
        {
            time += Time.deltaTime;

            var mat = FrozenScreen.sharedMaterial.GetFloat("_Frozen_Boundary");

            FrozenScreen.sharedMaterial.SetFloat("_Frozen_Boundary", mat + Time.deltaTime*5);

            if (mat > 5)
            {
                FrozenScreen.sharedMaterial.SetFloat("_Frozen_Boundary", 5);
            }
        }
    }
}
