__author__ = 'oliver'

import unittest
import sys

sys.path.append( '../' )

from mock import MagicMock

from common.applications import *

class TestApplication(unittest.TestCase):

    def setUp(self):
        self.data = "123"
        self.application = Applications()

        self.test_application = "testapplication"
        self.create_record = {
            "name": self.test_application
        }

        self.update_record = {
            "urls": "testapplication.localdomain.com",
            "memory_in_mb": "128",
            "command": "test command",
            "docker_image": "test/dockerimage",
            "type": "web"
        }

    def tearDown(self):
        self.teardown_application_record()
        pass

    def setup_application_record(self):
        try:
            output = self.application.get(self.test_application)
        except:
            output = None

        if output:
            output = self.application.delete_application(self.test_application)

        output = self.application.create_application(self.create_record)
        return output

    def teardown_application_record(self):
        try:
            output = self.application.delete_application(self.test_application)
        except Exception:
            print "Record does not exist"

    def test_application_lifecycle(self):
        self.setup_application_record()
        try:
            output = self.application.get(self.test_application)
        except:
            output = None

        if output:
            output = self.application.delete_application(self.test_application)
            self.assertEqual("Application {} deleted".format(self.test_application), output['message'])


        output = self.application.create_application(self.create_record)

        self.assertEqual(self.test_application, output['name'])
        self.assertEqual("NEW", output['state'])
        self.assertEqual("128", output['memory_in_mb'])
        self.assertEqual("testapplication", output['urls'])
        self.assertEqual("web", output['type'])

        output = self.application.get_all()
        self.assertEquals({ "data": ["testapplication"] }, output)

        output = self.application.get(self.test_application)
        self.assertEqual(self.test_application, output['name'])

        output = self.application.delete_application(self.test_application)
        self.assertEqual("Application {} deleted".format(self.test_application), output['message'])

    def test_parameters(self):
        output = self.setup_application_record()

        self.assertEqual(output['name'], "testapplication")

        output = self.application.update_application(self.test_application,self.update_record)
        self.assertEqual(output['urls'], self.update_record['urls'])
        self.assertEqual(output['memory_in_mb'], self.update_record['memory_in_mb'])
        self.assertEqual(output['docker_image'], self.update_record['docker_image'])
        self.assertEqual(output['command'], self.update_record['command'])
        self.assertEqual(output['type'], self.update_record['type'])

    def test_invalid_slug_url(self):
        output = self.setup_application_record()

        with self.assertRaises(Exception) as context:
            self.application.update_application(self.test_application, { "environment": { "SLUG_URL": "invalid_url" }})
        self.assertRegexpMatches(context.exception.message, "Slug URL invalid_url is either invalid or inaccessible")

    def test_application_restart(self):
        output = self.setup_application_record()

        self.assertEqual(output['name'], "testapplication")

        output = self.application.update_application(self.test_application, { 'restart': 'true' })
        self.assertEqual(output['environment']['RESTART'], '1', output)

        output = self.application.update_application(self.test_application, { 'restart': 'true' })
        self.assertEqual(output['environment']['RESTART'], '2')








